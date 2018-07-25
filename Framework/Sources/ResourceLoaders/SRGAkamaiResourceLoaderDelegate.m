//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGAkamaiToken.h"
#import "SRGContentProtectionError.h"

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
        self.request = [SRGAkamaiToken tokenizeURL:URL withSession:self.session completionBlock:^(NSURL *tokenizedURL) {
            NSURLRequest *playlistRequest = [NSURLRequest requestWithURL:tokenizedURL];
            self.request = [[SRGNetworkRequest alloc] initWithURLRequest:playlistRequest session:self.session options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"This stream is protected and cannot be read without proper rights.", @"User-facing message displayed when an error related to digital rights management (DRM) has been encountered") } mutableCopy];
                        if (error) {
                            userInfo[NSUnderlyingErrorKey] = error;
                        }
                        NSError *friendlyError = [NSError errorWithDomain:SRGContentProtectionErrorDomain code:SRGContentProtectionErrorUnauthorized userInfo:[userInfo copy]];
                        [loadingRequest finishLoadingWithError:friendlyError];
                        return;
                    }
                    else {
                        [loadingRequest.dataRequest respondWithData:data];
                        [loadingRequest finishLoading];
                    }
                });
            }];
            [self.request resume];
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
