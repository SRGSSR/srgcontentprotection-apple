//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGFairPlayAssetResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "NSData+SRGContentProtection.h"
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
@property (nonatomic) SRGRequestQueue *requestQueue;

@end

@implementation SRGFairPlayAssetResourceLoaderDelegate

#pragma mark Object lifecycle

- (instancetype)initWithCertificateURL:(NSURL *)certificateURL
{
    if (self = [super init]) {
        self.certificateURL = certificateURL;
        self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
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
    NSString *serviceName = self.options[SRGResourceLoaderOptionDiagnosticServiceNameKey];
    NSString *reportName = self.options[SRGResourceLoaderOptionDiagnosticReportNameKey];
    if (serviceName && reportName) {
        return [[[SRGDiagnosticsService serviceWithName:serviceName] reportWithName:reportName] informationForKey:@"drmResult"];
    }
    else {
        return nil;
    }
}

- (NSString *)contentKeysDirectoryURLString
{
    static NSString *s_contentKeysDirectoryURLString;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        NSString *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        s_contentKeysDirectoryURLString = [[libraryDirectory stringByAppendingPathComponent:[NSBundle.srg_contentProtectionBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey]] stringByAppendingPathComponent:@".keys"];
        NSError *error = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:s_contentKeysDirectoryURLString
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&error];
    });
    return s_contentKeysDirectoryURLString;
}

- (NSString *)contentKeyStoreURLStringForIdentifier:(NSData *)identifier
{
    return [[self contentKeysDirectoryURLString] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.key", identifier.sha1]];
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
    
    AVAssetResourceLoadingContentInformationRequest *contentInformationRequest = loadingRequest.contentInformationRequest;
    NSData *contentIdentifier = [loadingRequest.request.URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
    
    self.requestQueue = [[SRGRequestQueue alloc] init];
    
    if (@available(iOS 11.2, *)) {
        if ([contentInformationRequest.allowedContentTypes containsObject:AVStreamingKeyDeliveryPersistentContentKeyType]) {
            contentInformationRequest.contentType = AVStreamingKeyDeliveryPersistentContentKeyType;
            
            NSData *persistentContentKeyData = [self persistentContentKeyForIdentifier:contentIdentifier];
            if (persistentContentKeyData) {
                NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
                components.scheme = @"https";
                [self finishLoadingRequest:loadingRequest withContentKeyContextData:persistentContentKeyData HTTPResponse:nil offlineURL:components.URL error:nil];
                return YES;
            }
        }
    }
    
    SRGRequest *request = [[SRGRequest dataRequestWithURLRequest:[NSURLRequest requestWithURL:self.certificateURL] session:self.session completionBlock:^(NSData * _Nullable certificateData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *HTTPResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
        
        // Resource loader methods must be called on the main thread
        if (error) {
            [self finishLoadingRequest:loadingRequest withContentKeyContextData:nil HTTPResponse:HTTPResponse offlineURL:nil error:error];
            return;
        }
        
        // TODO: - Content identifier convention?
        NSError *keyError = nil;
        NSDictionary *options = nil;
        NSData *contentIdentifier = [loadingRequest.request.URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
        if (contentInformationRequest.contentType == AVStreamingKeyDeliveryPersistentContentKeyType) {
            options = @{ AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey : @YES };
        }
        NSData *keyRequestData = [loadingRequest streamingContentKeyRequestDataForApp:certificateData
                                                                    contentIdentifier:contentIdentifier
                                                                              options:options
                                                                                error:&keyError];
        if (keyError) {
            [self finishLoadingRequest:loadingRequest withContentKeyContextData:nil HTTPResponse:HTTPResponse offlineURL:nil error:keyError];
            return;
        }
        
        NSURLRequest *contentKeyContextRequest = SRGFairPlayContentKeyContextRequest(URL, keyRequestData);
        SRGRequest *request = [[SRGRequest dataRequestWithURLRequest:contentKeyContextRequest session:self.session completionBlock:^(NSData * _Nullable contentKeyContextData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *HTTPResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
            if (contentInformationRequest.contentType == AVStreamingKeyDeliveryPersistentContentKeyType) {
                NSError *persistentContentKeyError = nil;
                NSData *persistentContentKeyData = [loadingRequest persistentContentKeyFromKeyVendorResponse:contentKeyContextData options:nil error:&persistentContentKeyError];
                if (! persistentContentKeyError && persistentContentKeyData) {
                    [self savePersistentContentKey:persistentContentKeyData forIdentifier:contentIdentifier];
                    contentKeyContextData = persistentContentKeyData;
                }
            }
            [self finishLoadingRequest:loadingRequest withContentKeyContextData:contentKeyContextData HTTPResponse:HTTPResponse offlineURL:nil error:error];
        }] requestWithOptions:SRGRequestOptionBackgroundCompletionEnabled];
        [self.requestQueue addRequest:request resume:YES];
    }] requestWithOptions:SRGRequestOptionBackgroundCompletionEnabled];
    [self.requestQueue addRequest:request resume:YES];
    return YES;
}

- (void)didCancelResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.requestQueue cancel];
}

#pragma mark Helpers

- (void)finishLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest withContentKeyContextData:(NSData *)contentKeyContextData HTTPResponse:(NSHTTPURLResponse *)HTTPResponse offlineURL:(NSURL *)offlineURL error:(NSError *)error
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
    if (HTTPResponse) {
        [diagnosticInformation setURL:HTTPResponse.URL forKey:@"url"];
        [diagnosticInformation setInteger:HTTPResponse.statusCode forKey:@"httpStatusCode"];
        [diagnosticInformation setBool:NO forKey:@"offline"];
    }
    
    if (offlineURL) {
        [diagnosticInformation setURL:offlineURL forKey:@"url"];
        [diagnosticInformation setBool:YES forKey:@"offline"];
    }
    
    [diagnosticInformation setString:error.localizedDescription forKey:@"errorMessage"];
    [diagnosticInformation stopTimeMeasurementForKey:@"duration"];
}

- (void)savePersistentContentKey:(NSData *)persistentContentKey forIdentifier:(NSData *)identifier
{
    if (! [persistentContentKey writeToFile:[self contentKeyStoreURLStringForIdentifier:identifier] atomically:YES]) {
        NSAssert(NO, @"Could not save contentKey. Not safe. See error above.");
    }
}

- (NSData *)persistentContentKeyForIdentifier:(NSData *)identifier
{
    return [NSData dataWithContentsOfFile:[self contentKeyStoreURLStringForIdentifier:identifier]];
}

@end
