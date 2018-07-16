//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "NSHTTPURLResponse+SRGContentProtection.h"
#import "SRGContentProtectionError.h"
#import "SRGContentProtectionURL.h"

typedef void (^SRGURLCompletionBlock)(NSURL * _Nullable URL, NSError * _Nullable error);

static NSString * const SRGTokenServiceURLString = @"https://tp.srgssr.ch/akahd/token";

@interface SRGAkamaiResourceLoaderDelegate ()

@property (nonatomic) NSURLSessionTask *sessionTask;

@end

@implementation SRGAkamaiResourceLoaderDelegate

#pragma mark Common resource loading request processing

- (BOOL)shouldProcessResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSURL *URL = SRGContentProtectionUnwrapURL(loadingRequest.request.URL, SRGContentProtectionAkamaiToken);
    if (! URL) {
        return NO;
    }
    
    self.sessionTask = [SRGAkamaiResourceLoaderDelegate tokenizeURL:URL withCompletionBlock:^(NSURL * _Nullable tokenizedURL, NSError * _Nullable error) {
        if (error) {
            [loadingRequest finishLoadingWithError:error];
            return;
        }
        
        // Update original URL with tokenized URL
        NSMutableURLRequest *redirect = [loadingRequest.request mutableCopy];
        redirect.URL = tokenizedURL;
        loadingRequest.redirect = [redirect copy];
        
        // Force redirect to the new tokenized URL
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:tokenizedURL statusCode:303 HTTPVersion:nil headerFields:nil];
        [loadingRequest setResponse:response];
        
        [loadingRequest finishLoading];
    }];
    [self.sessionTask resume];
    
    return YES;
}

#pragma mark Tokenization

+ (NSURLSessionTask *)tokenizeURL:(NSURL *)URL withCompletionBlock:(SRGURLCompletionBlock)completionBlock
{
    NSParameterAssert(URL);
    NSParameterAssert(completionBlock);
    NSAssert([URL.host containsString:@"akamai"], @"Only Akamai URLs can be tokenized");
    
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSString *acl = [URLComponents.path.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"*"];
    
    NSURLComponents *tokenServiceURLComponents = [NSURLComponents componentsWithURL:[NSURL URLWithString:SRGTokenServiceURLString] resolvingAgainstBaseURL:NO];
    tokenServiceURLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"acl" value:acl] ];
    
    // TODO: The following code is currently duplicated with SRG Data Provider, but will be common when SRGNetwork is introduced.
    //       Factoring it out now would be premature.
    NSURLRequest *request = [NSURLRequest requestWithURL:tokenServiceURLComponents.URL];
    return [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        SRGURLCompletionBlock requestCompletionBlock = ^(NSURL * _Nullable URL, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(URL, error);
            });
        };
        
        if (error) {
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                return;
            }
            else {
                requestCompletionBlock(nil, error);
            }
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            NSInteger HTTPStatusCode = HTTPURLResponse.statusCode;
            
            // Properly handle HTTP error codes >= 400 as real errors
            if (HTTPStatusCode >= 400) {
                NSError *HTTPError = [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                         code:SRGContentProtectionErrorHTTP
                                                     userInfo:@{ NSLocalizedDescriptionKey : [NSHTTPURLResponse srg_contentProtection_localizedStringForStatusCode:HTTPStatusCode],
                                                                 NSURLErrorKey : response.URL,
                                                                 SRGContentProtectionHTTPStatusCodeKey : @(HTTPStatusCode) }];
                requestCompletionBlock(nil, HTTPError);
                return;
            }
            // Block redirects and return an error with URL information. Currently no redirection is expected for IL services, this
            // means redirection is probably related to a public hotspot with login page (e.g. SBB)
            else if (HTTPStatusCode >= 300) {
                NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"You are likely connected to a public wifi network with no Internet access", @"The error message when request a media or a media list on a public network with no Internet access (e.g. SBB)"),
                                                    NSURLErrorKey : response.URL } mutableCopy];
                
                NSString *redirectionURLString = HTTPURLResponse.allHeaderFields[@"Location"];
                if (redirectionURLString) {
                    NSURL *redirectionURL = [NSURL URLWithString:redirectionURLString];
                    userInfo[SRGContentProtectionRedirectionURLKey] = redirectionURL;
                }
                
                NSError *redirectError = [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                             code:SRGContentProtectionErrorRedirect
                                                         userInfo:[userInfo copy]];
                requestCompletionBlock(nil, redirectError);
                return;
            }
        }
        
        id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONDictionary || ! [JSONDictionary isKindOfClass:[NSDictionary class]]) {
            NSError *dataFormatError = [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                           code:SRGContentProtectionErrorCodeInvalidData
                                                       userInfo:@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"The data is invalid.", @"The error message when the response from IL server is incorrect.") }];
            requestCompletionBlock(nil, dataFormatError);
            return;
        }
        
        NSString *token = nil;
        id tokenDictionary = JSONDictionary[@"token"];
        if ([tokenDictionary isKindOfClass:[NSDictionary class]]) {
            token = [tokenDictionary objectForKey:@"authparams"];
        }
        
        if (! token) {
            requestCompletionBlock(nil, [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                            code:SRGContentProtectionErrorCodeInvalidData
                                                        userInfo:@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"The stream could not be secured.", @"The error message when the secure token cannot be retrieved to play the media stream.") }]);
            return;
        }
        
        // Use components to properly extract the token as query items
        NSURLComponents *tokenURLComponents = [[NSURLComponents alloc] init];
        tokenURLComponents.query = token;
        
        // Build the tokenized URL, merging token components with existing ones
        NSURLComponents *tokenizedURLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
        
        NSMutableArray *queryItems = [tokenizedURLComponents.queryItems mutableCopy] ?: [NSMutableArray array];
        if (tokenURLComponents.queryItems) {
            [queryItems addObjectsFromArray:tokenURLComponents.queryItems];
        }
        tokenizedURLComponents.queryItems = [queryItems copy];
        
        requestCompletionBlock(tokenizedURLComponents.URL, nil);
    }];
}

#pragma mark AVAssetResourceLoaderDelegate protocol

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    return [self shouldProcessResourceLoadingRequest:loadingRequest];
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest
{
    return [self shouldProcessResourceLoadingRequest:renewalRequest];
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.sessionTask cancel];
}

@end
