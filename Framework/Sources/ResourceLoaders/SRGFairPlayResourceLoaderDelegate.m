//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFairPlayResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGContentProtectionError.h"

#import <SRGNetwork/SRGNetwork.h>

// TODO: Must be configurable?
static NSString * const SRGFairPlayApplicationIdentifier = @"stage";

static NSURLRequest *SRGFairPlayApplicationCertificateURLRequest(NSURL *URL)
{
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    if (! [URLComponents.scheme isEqualToString:@"skd"]) {
        return nil;
    }
    
    URLComponents.scheme = @"https";
    URLComponents.path = [URLComponents.path.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"getcertificate"];
    URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"applicationId" value:SRGFairPlayApplicationIdentifier] ];
    return [NSURLRequest requestWithURL:URLComponents.URL];
}

static NSURLRequest *SRGFairPlayContentKeyContextRequest(NSURL *URL, NSData *requestData)
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    components.scheme = @"https";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:components.URL];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    return [request copy];
}

@interface SRGFairPlayResourceLoaderDelegate ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGNetworkRequest *request;

@end

@implementation SRGFairPlayResourceLoaderDelegate

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
    NSURL *URL = loadingRequest.request.URL;
    NSURLRequest *certificateRequest = SRGFairPlayApplicationCertificateURLRequest(URL);
    if (! certificateRequest) {
        return NO;
    }
    
    self.request = [[SRGNetworkRequest alloc] initWithURLRequest:certificateRequest session:self.session options:0 completionBlock:^(NSData * _Nullable certificateData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Resource loader methods must be called on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self finishLoadingRequest:loadingRequest withContentKeyContextData:nil error:error];
                return;
            }
            
            // TODO: - Content identifier convention?
            NSError *keyError = nil;
            NSData *contentIdentifier = [URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
            NSData *keyRequestData = [loadingRequest streamingContentKeyRequestDataForApp:certificateData
                                                                        contentIdentifier:contentIdentifier
                                                                                  options:nil
                                                                                    error:&keyError];
            if (keyError) {
                [self finishLoadingRequest:loadingRequest withContentKeyContextData:nil error:keyError];
                return;
            }
            
            NSURLRequest *contentKeyContextRequest = SRGFairPlayContentKeyContextRequest(URL, keyRequestData);
            self.request = [[SRGNetworkRequest alloc] initWithURLRequest:contentKeyContextRequest session:self.session options:0 completionBlock:^(NSData * _Nullable contentKeyContextData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [self finishLoadingRequest:loadingRequest withContentKeyContextData:nil error:error];
                        return;
                    }
                    
                    [self finishLoadingRequest:loadingRequest withContentKeyContextData:contentKeyContextData error:nil];
                });
            }];
            [self.request resume];
        });
    }];
    [self.request resume];
    
    return YES;
}

- (void)finishLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest withContentKeyContextData:(NSData *)contentKeyContextData error:(NSError *)error
{
    NSAssert([NSThread isMainThread], @"Must only be called from the main thread");
    
    if (contentKeyContextData) {
        [loadingRequest.dataRequest respondWithData:contentKeyContextData];
        [loadingRequest finishLoading];
    }
    else {
        NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"Rights to play the content could not be obtained.", @"User-facing message displayed when an error related to digital rights management (DRM) has been encountered") } mutableCopy];
        if (error) {
            userInfo[NSUnderlyingErrorKey] = error;
        }
        NSError *friendlyError = [NSError errorWithDomain:SRGContentProtectionErrorDomain code:SRGContentProtectionErrorUnauthorized userInfo:[userInfo copy]];
        [loadingRequest finishLoadingWithError:friendlyError];
    }
}

#pragma mark AVAssetResourceLoaderDelegate protocol

// For FairPlay-protected streams, only called on a device
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    return [self shouldProcessResourceLoadingRequest:loadingRequest];
}

// For FairPlay-protected streams, only called on a device
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest
{
    return [self shouldProcessResourceLoadingRequest:renewalRequest];
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.request cancel];
}

@end
