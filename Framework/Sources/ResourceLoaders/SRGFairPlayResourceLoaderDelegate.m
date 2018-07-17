//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFairPlayResourceLoaderDelegate.h"

#import "SRGContentProtectionURL.h"
#import "SRGContentProtectionRequestService.h"

// TODO: Must be configurable?
static NSString * const SRGFairPlayApplicationIdentifier = @"stage";

static NSURL *SRGFairPlayApplicationCertificateURL(NSURL *URL)
{
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    if (! [URLComponents.scheme isEqualToString:@"skd"]) {
        return nil;
    }
    
    URLComponents.scheme = @"https";
    URLComponents.path = [URLComponents.path.stringByDeletingLastPathComponent stringByAppendingPathComponent:@"getcertificate"];
    URLComponents.queryItems = @[ [NSURLQueryItem queryItemWithName:@"applicationId" value:SRGFairPlayApplicationIdentifier] ];
    return URLComponents.URL;
}

@interface SRGFairPlayResourceLoaderDelegate ()

@property (nonatomic) NSURLSessionTask *sessionTask;

@end

@implementation SRGFairPlayResourceLoaderDelegate

#pragma mark Common resource loading request processing

- (BOOL)shouldProcessResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSURL *URL = SRGContentProtectionRoutedURL(loadingRequest.request.URL, SRGContentProtectionFairPlay);
    if (! URL) {
        return NO;
    }
    
    NSURL *applicationCertificateURL = SRGFairPlayApplicationCertificateURL(URL);
    if (! applicationCertificateURL) {
        return NO;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:applicationCertificateURL];
    [[[SRGContentProtectionRequestService sharedService] asynchronousDataRequest:request withCompletionBlock:^(NSData * _Nullable certificateData, NSError * _Nullable error) {
        if (error) {
            [loadingRequest finishLoadingWithError:error];
            return;
        }
        
        // TODO: - Content identifier convention
        //       - Is the error suitable for display?
        NSError *keyError = nil;
        NSData *keyData = [loadingRequest streamingContentKeyRequestDataForApp:certificateData
                                                             contentIdentifier:[URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:nil
                                                                         error:&keyError];
        if (keyError) {
            [loadingRequest finishLoadingWithError:keyError];
            return;
        }
        
        // TODO: Use key!
    }] resume];
    
    return YES;
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
    
}

@end
