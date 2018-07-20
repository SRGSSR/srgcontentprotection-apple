//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGContentProtectionError.h"
#import "SRGContentProtectionURL.h"

#import <SRGNetwork/SRGNetwork.h>

static NSString * const SRGTokenServiceURLString = @"https://tp.srgssr.ch/akahd/token";

@interface SRGAkamaiResourceLoaderDelegate ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGNetworkRequest *request;

@end

@implementation SRGAkamaiResourceLoaderDelegate

#pragma mark Object lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

#pragma mark Common resource loading request processing

- (BOOL)shouldProcessResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSURL *URL = SRGContentProtectionRoutedURL(loadingRequest.request.URL, SRGContentProtectionAkamaiToken);
    if (! URL) {
        return NO;
    }
    
    if (! [URL.host containsString:@"akamai"]) {
        return NO;
    }
    
    self.request = [self tokenizeURL:URL withCompletionBlock:^(NSURL *tokenizedURL, NSError *error) {
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
    [self.request resume];
    
    return YES;
}

#pragma mark Tokenization

- (SRGNetworkRequest *)tokenizeURL:(NSURL *)URL withCompletionBlock:(void (^)(NSURL *URL, NSError *error))completionBlock
{
    NSParameterAssert(URL);
    NSParameterAssert(completionBlock);
    
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSString *acl = [URLComponents.path.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"*"];
    
    NSURLComponents *tokenServiceURLComponents = [NSURLComponents componentsWithURL:[NSURL URLWithString:SRGTokenServiceURLString] resolvingAgainstBaseURL:NO];
    tokenServiceURLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"acl" value:acl] ];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:tokenServiceURLComponents.URL];
    return [[SRGNetworkRequest alloc] initWithJSONDictionaryURLRequest:request session:self.session options:0 completionBlock:^(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *token = nil;
        id tokenDictionary = JSONDictionary[@"token"];
        if ([tokenDictionary isKindOfClass:[NSDictionary class]]) {
            token = [tokenDictionary objectForKey:@"authparams"];
        }
        
        if (! token) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                         code:SRGContentProtectionErrorUnauthorized
                                                     userInfo:@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"The stream could not be secured.", @"The error message when the secure token cannot be retrieved to play the media stream.") }]);
            });
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(tokenizedURLComponents.URL, nil);
        });
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
    [self.request cancel];
}

@end
