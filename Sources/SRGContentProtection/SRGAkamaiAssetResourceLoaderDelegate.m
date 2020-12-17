//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAkamaiAssetResourceLoaderDelegate.h"

#import "NSBundle+SRGContentProtection.h"
#import "SRGAkamaiToken.h"
#import "SRGContentProtectionError.h"

@import SRGDiagnostics;

static NSString * const SRGStandardURLSchemePrefix = @"akamai";

@interface SRGAkamaiAssetResourceLoaderDelegate ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) SRGRequestQueue *requestQueue;

@end

@implementation SRGAkamaiAssetResourceLoaderDelegate

#pragma mark Class methods

- (NSURL *)URLForAssetURL:(NSURL *)URL
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    
    NSArray<NSString *> *schemeComponents = [components.scheme componentsSeparatedByString:@"+"];
    if (schemeComponents.count != 2 || ! [schemeComponents.firstObject isEqualToString:SRGStandardURLSchemePrefix]) {
        return nil;
    }
    
    components.scheme = schemeComponents.lastObject;
    return components.URL;
}

#pragma mark Object lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        self.session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    }
    return self;
}

#pragma mark Getters and setters

- (SRGDiagnosticInformation *)diagnosticInformation
{
    NSString *serviceName = self.options[SRGResourceLoaderOptionDiagnosticServiceNameKey];
    NSString *reportName = self.options[SRGResourceLoaderOptionDiagnosticReportNameKey];
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
    // About thread-safety considerations: The delegate methods are called from background threads, and though there is
    // no explicit documentation, Apple examples show that completion calls can be made from background threads. There
    // is probably no need to dispatch any work to the main thread.
    NSURL *requestURL = [self URLForAssetURL:loadingRequest.request.URL];
    if (! requestURL) {
        return NO;
    }
    
    SRGDiagnosticInformation *diagnosticInformation = [self diagnosticInformation];
    [diagnosticInformation startTimeMeasurementForKey:@"duration"];
    
    self.requestQueue = [[SRGRequestQueue alloc] init];

    SRGRequest *request = [[SRGAkamaiToken tokenizeURL:requestURL withSession:self.session completionBlock:^(NSURL * _Nonnull URL, NSHTTPURLResponse * _Nonnull HTTPResponse, NSError * _Nullable error) {
        [diagnosticInformation setURL:HTTPResponse.URL forKey:@"url"];
        [diagnosticInformation setInteger:HTTPResponse.statusCode forKey:@"httpStatusCode"];
        [diagnosticInformation setString:error.localizedDescription forKey:@"errorMessage"];
        [diagnosticInformation stopTimeMeasurementForKey:@"duration"];
        
        // Retrieve the master playlist to find how we shopuld respond to the loading request for maximum compatibility.
        NSMutableURLRequest *playlistRequest = loadingRequest.request.mutableCopy;
        playlistRequest.URL = URL;
        SRGRequest *request = [[SRGRequest dataRequestWithURLRequest:playlistRequest session:self.session completionBlock:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            loadingRequest.response = response;
            if (error) {
                NSMutableDictionary *userInfo = @{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"This content is protected and cannot be played without proper rights.", @"User-facing message displayed proper authorization to play a stream has not been obtained") }.mutableCopy;
                if (error) {
                    userInfo[NSUnderlyingErrorKey] = error;
                }
                NSError *friendlyError = [NSError errorWithDomain:SRGContentProtectionErrorDomain code:SRGContentProtectionErrorUnauthorized userInfo:userInfo.copy];
                [loadingRequest finishLoadingWithError:friendlyError];
            }
            else {
                NSString *masterPlaylistString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                // If #EXT-X-STREAM-INF are absolute URLs, the master playlist we retrieved can be provided as response
                // data to the loading request. This works on all iOS and tvOS versions we support, and also when casting
                // to any Apple TV receiver via AirPlay (including old receivers like Apple TV 3rd gen which uses an even
                // older version of tvOS).
                //
                // Remark: Absolute URLs are required for iOS / tvOS 9 and 10 compatibilty, otherwise the stream will
                //         not play. See https://github.com/SRGSSR/srgcontentprotection-apple/issues/6. Playlists with
                //         relative URLs will not play correctly.
                if ([masterPlaylistString containsString:@"\nhttp"]) {
                    [loadingRequest.dataRequest respondWithData:data];
                    [loadingRequest finishLoading];
                }
                // If partial URLs are detected, simply redirect to the tokenized URL. This restores original scheme URL and
                // preserves cookies on iOS 11+ and tvOS 11+. This does not work on older iOS and tvOS versions, but there
                // is nothing else we can do for them.
                //
                // Remark: The redirect approach also works fine on iOS 11+ and tvOS 11+ if the master playlist contains
                //         absolute URLs. But still we have to provide the response directly, as an iOS 11+ device can
                //         cast to an old Apple TV 3rd gen receiver which would not support the redirect.
                else {
                    NSMutableURLRequest *redirect = loadingRequest.request.mutableCopy;
                    redirect.URL = URL;
                    loadingRequest.redirect = redirect.copy;
                    
                    loadingRequest.response = [[NSHTTPURLResponse alloc] initWithURL:URL statusCode:303 HTTPVersion:nil headerFields:nil];
                    [loadingRequest finishLoading];
                }
            }
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

@end
