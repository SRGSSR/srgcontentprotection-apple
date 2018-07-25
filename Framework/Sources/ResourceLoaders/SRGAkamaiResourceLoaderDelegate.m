//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGContentProtectionError.h"

#import <SRGNetwork/SRGNetwork.h>

static NSString * const SRGTokenServiceURLString = @"https://tp.srgssr.ch/akahd/token";

@interface SRGAkamaiResourceLoaderDelegate ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGNetworkRequest *request;

@end

@implementation SRGAkamaiResourceLoaderDelegate

#pragma mark Class methods

/**
 *  Use non-standard scheme unkwown to AirPlay receivers like the Apple TV. This ensures that the resource
 *  loader delegate is used (if the resource is simply an HTTP one, the receiver thinks it can handle it,
 *  and does not call the resource loader delegate).
 *
 *  See https://stackoverflow.com/a/30154884/760435
 */
+ (NSURL *)assetURLForURL:(NSURL *)URL
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    components.scheme = [@[ @"akamai", components.scheme ] componentsJoinedByString:@"+"];
    return components.URL;
}

+ (NSURL *)URLForAssetURL:(NSURL *)URL
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSArray<NSString *> *schemeComponents = [components.scheme componentsSeparatedByString:@"+"];
    NSAssert(schemeComponents.count == 2 && [schemeComponents.firstObject isEqualToString:@"akamai"], @"The URL must be a valid Akamai asset URL");
    components.scheme = schemeComponents.lastObject;
    return components.URL;
}

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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *URL = [SRGAkamaiResourceLoaderDelegate URLForAssetURL:loadingRequest.request.URL];
        self.request = [self tokenizeURL:URL withCompletionBlock:^(NSURL *tokenizedURL) {
            NSMutableURLRequest *redirect = [loadingRequest.request mutableCopy];
            redirect.URL = tokenizedURL;
            loadingRequest.redirect = [redirect copy];
            
            // Force redirect to the new tokenized URL
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:tokenizedURL statusCode:303 HTTPVersion:nil headerFields:nil];
            [loadingRequest setResponse:response];
            
            [loadingRequest finishLoading];
        }];
        [self.request resume];
    });
    return YES;
}

#pragma mark Tokenization

// The completion block is called on the main thread
- (SRGNetworkRequest *)tokenizeURL:(NSURL *)URL withCompletionBlock:(void (^)(NSURL *URL))completionBlock
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
        
        // On failure, just return the untokenized URL, which might be playable as is
        if (! token) {
            completionBlock(URL);
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
            completionBlock(tokenizedURLComponents.URL);
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.request cancel];
    });
}

@end
