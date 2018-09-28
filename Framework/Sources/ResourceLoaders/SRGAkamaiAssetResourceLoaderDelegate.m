//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiAssetResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGAkamaiToken.h"
#import "SRGContentProtectionError.h"

#import <SRGDiagnostics/SRGDiagnostics.h>

static NSString * const SRGStandardURLSchemePrefix = @"akamai";

@interface SRGAkamaiAssetResourceLoaderDelegate ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGNetworkRequest *request;

@end

@implementation SRGAkamaiAssetResourceLoaderDelegate

#pragma mark Class methods

- (NSURL *)URLForAssetURL:(NSURL *)URL
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSArray<NSString *> *schemeComponents = [components.scheme componentsSeparatedByString:@"+"];
    NSAssert(schemeComponents.count == 2 && [schemeComponents.firstObject isEqualToString:SRGStandardURLSchemePrefix], @"The URL must be a valid Akamai URL");
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

#pragma mark Getters and setters

- (SRGDiagnosticInformation *)diagnosticInformation
{
    NSString *serviceName = self.options[SRGAssetOptionDiagnosticServiceNameKey];
    NSString *reportName = self.options[SRGAssetOptionDiagnosticReportNameKey];
    if (serviceName && reportName) {
        return [[[SRGDiagnosticsService serviceWithName:serviceName] reportWithName:reportName] informationForKey:@"tokenResult"];
    }
    else {
        return nil;
    }
}

#pragma mark Subclassing hooks

- (NSURL *)assetURLForURL:(NSURL *)URL
{
    /**
     *  Use non-standard scheme unkwown to AirPlay receivers like the Apple TV. This ensures that the resource
     *  loader delegate is used (if the resource is simply an HTTP one, the receiver thinks it can handle it,
     *  and does not call the resource loader delegate).
     *
     *  See https://stackoverflow.com/a/30154884/760435
     */
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    components.scheme = [@[ SRGStandardURLSchemePrefix, components.scheme ] componentsJoinedByString:@"+"];
    return components.URL;
}

- (BOOL)shouldProcessResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    SRGDiagnosticInformation *diagnosticInformation = [self diagnosticInformation];
    [diagnosticInformation startTimeMeasurementForKey:@"duration"];
    
    // About thread-safety considerations: The delegate methods are called from background threads, and though there is
    // no explicit documentation, Apple examples show that completion calls can be made from background threads. There
    // is probably no need to dispatch any work to the main thread.
    NSURL *requestURL = [self URLForAssetURL:loadingRequest.request.URL];
    self.request = [SRGAkamaiToken tokenizeURL:requestURL withSession:self.session completionBlock:^(NSURL * _Nonnull URL, NSHTTPURLResponse * _Nonnull HTTPResponse, NSError * _Nullable error) {
        [diagnosticInformation setURL:HTTPResponse.URL forKey:@"url"];
        [diagnosticInformation setInteger:HTTPResponse.statusCode forKey:@"httpStatusCode"];
        [diagnosticInformation setString:error.localizedDescription forKey:@"message"];
        [diagnosticInformation stopTimeMeasurementForKey:@"duration"];
        
        NSMutableURLRequest *playlistRequest = [loadingRequest.request mutableCopy];
        playlistRequest.URL = URL;
        self.request = [[SRGNetworkRequest alloc] initWithURLRequest:playlistRequest session:self.session options:0 completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            loadingRequest.response = response;
            if (error) {
                NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"This content is protected and cannot be played without proper rights.", @"User-facing message displayed proper authorization to play a stream has not been obtained") } mutableCopy];
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

@end
