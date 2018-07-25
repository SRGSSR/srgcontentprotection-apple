//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGAkamaiTokenService.h"
#import "SRGContentProtectionError.h"

@interface SRGAkamaiResourceLoaderDelegate ()

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

#pragma mark Common resource loading request processing

- (BOOL)shouldProcessResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *URL = [SRGAkamaiResourceLoaderDelegate URLForAssetURL:loadingRequest.request.URL];
        self.request = [[SRGAkamaiTokenService sharedService] tokenizeURL:URL withCompletionBlock:^(NSURL *tokenizedURL) {
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
