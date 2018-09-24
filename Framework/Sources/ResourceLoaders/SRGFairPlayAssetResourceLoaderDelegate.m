//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFairPlayAssetResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGContentProtectionConstants.h"
#import "SRGContentProtectionError.h"

#import <SRGDiagnostics/SRGDiagnostics.h>
#import <SRGNetwork/SRGNetwork.h>

static BOOL SRGIsFairPlayURL(NSURL *URL)
{
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    return [URLComponents.scheme isEqualToString:@"skd"];
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

@interface SRGFairPlayAssetResourceLoaderDelegate ()

@property (nonatomic) NSURL *certificateURL;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGNetworkRequest *request;

@end

@implementation SRGFairPlayAssetResourceLoaderDelegate

#pragma mark Object lifecycle

- (instancetype)initWithCertificateURL:(NSURL *)certificateURL
{
    if (self = [super init]) {
        self.certificateURL = certificateURL;
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return [self initWithCertificateURL:[NSURL new]];
}

#pragma mark Getters and setters

- (SRGDiagnosticInformation *)diagnosticInformation
{
    NSString *serviceName = self.options[SRGAssetOptionDiagnosticServiceNameKey];
    NSString *reportName = self.options[SRGAssetOptionDiagnosticReportNameKey];
    if (serviceName && reportName) {
        return [[[SRGDiagnosticsService serviceWithName:serviceName] reportWithName:reportName] informationForKey:@"drmResult"];
    }
    else {
        return nil;
    }
}

#pragma clang diagnostic pop

#pragma mark Subclassing hooks

// For FairPlay-protected streams, only called on a device
- (BOOL)shouldProcessResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    // About thread-safety considerations: The delegate methods are called from background threads, and though there is
    // no explicit documentation, Apple examples show that completion calls are also made from background threads. There
    // is probably therefore no need to dispatch any work to the main thread.
    NSURL *URL = loadingRequest.request.URL;
    if (! SRGIsFairPlayURL(URL)) {
        return NO;
    }
    
    SRGDiagnosticInformation *diagnosticInformation = [self diagnosticInformation];
    [diagnosticInformation startTimeMeasurementForKey:@"duration"];
    
    self.request = [[SRGNetworkRequest alloc] initWithURLRequest:[NSURLRequest requestWithURL:self.certificateURL] session:self.session options:0 completionBlock:^(NSData * _Nullable certificateData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Resource loader methods must be called on the main thread
        if (error) {
            [self finishLoadingRequest:loadingRequest withContentKeyContextData:nil error:error];
            return;
        }
        
        // TODO: - Content identifier convention?
        NSError *keyError = nil;
        NSData *contentIdentifier = [loadingRequest.request.URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
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
            [self finishLoadingRequest:loadingRequest withContentKeyContextData:contentKeyContextData error:error];
        }];
        [self.request resume];
    }];
    [self.request resume];
    return YES;
}

- (void)didCancelResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.request cancel];
}

#pragma mark Helpers

- (void)finishLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest withContentKeyContextData:(NSData *)contentKeyContextData error:(NSError *)error
{
    if (contentKeyContextData) {
        [loadingRequest.dataRequest respondWithData:contentKeyContextData];
        [loadingRequest finishLoading];
    }
    else {
        NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"This content is protected and cannot be played without proper rights. Contact customer support for further help.", @"User-facing message displayed when an error related to digital rights management (DRM) has been encountered, and inviting the user to contact customer support") } mutableCopy];
        if (error) {
            userInfo[NSUnderlyingErrorKey] = error;
        }
        NSError *friendlyError = [NSError errorWithDomain:SRGContentProtectionErrorDomain code:SRGContentProtectionErrorUnauthorized userInfo:[userInfo copy]];
        [loadingRequest finishLoadingWithError:friendlyError];
    }
    
    SRGDiagnosticInformation *diagnosticInformation = [self diagnosticInformation];
    [diagnosticInformation setURL:loadingRequest.request.URL forKey:@"url"];
    
    NSHTTPURLResponse *HTTPResponse = [loadingRequest.response isKindOfClass:NSHTTPURLResponse.class] ? (NSHTTPURLResponse *)loadingRequest.response : nil;
    [diagnosticInformation setInteger:HTTPResponse.statusCode forKey:@"httpStatusCode"];
    [diagnosticInformation setString:error.localizedDescription forKey:@"message"];
    [diagnosticInformation stopTimeMeasurementForKey:@"duration"];
}

@end
