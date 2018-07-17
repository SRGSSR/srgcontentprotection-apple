//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionRequestService.h"

#import "NSBundle+SRGContentProtection.h"
#import "NSHTTPURLResponse+SRGContentProtection.h"
#import "SRGContentProtectionError.h"

@interface SRGContentProtectionRequestService ()

@property (nonatomic) NSURLSession *session;

@end

@implementation SRGContentProtectionRequestService

+ (instancetype)sharedService
{
    static dispatch_once_t s_onceToken;
    static SRGContentProtectionRequestService *s_sharedService;
    dispatch_once(&s_onceToken, ^{
        s_sharedService = [[SRGContentProtectionRequestService alloc] init];
    });
    return s_sharedService;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

- (NSURLSessionTask *)asynchronousDataRequest:(NSURLRequest *)request withCompletionBlock:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionBlock
{
    return [self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
                return;
            }
            else {
                completionBlock(nil, error);
            }
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
            NSInteger HTTPStatusCode = HTTPURLResponse.statusCode;
            
            // Properly handle HTTP error codes >= 400 as real errors
            if (HTTPStatusCode >= 400) {
                NSError *HTTPError = [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                         code:SRGContentProtectionErrorHTTP
                                                     userInfo:@{ NSLocalizedDescriptionKey : [NSHTTPURLResponse srg_contentProtection_localizedStringForStatusCode:HTTPStatusCode],
                                                                 NSURLErrorKey : response.URL,
                                                                 SRGContentProtectionHTTPStatusCodeKey : @(HTTPStatusCode) }];
                completionBlock(nil, HTTPError);
                return;
            }
            // Block redirects and return an error with URL information. Currently no redirection is expected for IL services, this
            // means redirection is probably related to a public hotspot with login page (e.g. SBB)
            else if (HTTPStatusCode >= 300) {
                NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"You are likely connected to a public wifi network with no Internet access", @"The error message when request a media or a media list on a public network with no Internet access (e.g. SBB)"),
                                                    NSURLErrorKey : response.URL } mutableCopy];
                
                NSString *redirectionURLString = HTTPURLResponse.allHeaderFields[@"Location"];
                if (redirectionURLString) {
                    NSURL *redirectionURL = [NSURL URLWithString:redirectionURLString];
                    userInfo[SRGContentProtectionRedirectionURLKey] = redirectionURL;
                }
                
                NSError *redirectError = [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                             code:SRGContentProtectionErrorRedirect
                                                         userInfo:[userInfo copy]];
                completionBlock(nil, redirectError);
                return;
            }
        }
        
        completionBlock(data, nil);
    }];
}

- (NSURLSessionTask *)asynchronousJSONDictionaryRequest:(NSURLRequest *)request withCompletionBlock:(void (^)(NSDictionary * _Nullable JSONDictionary, NSError * _Nullable error))completionBlock
{
    return [self asynchronousDataRequest:request withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        id JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if (! JSONDictionary || ! [JSONDictionary isKindOfClass:[NSDictionary class]]) {
            completionBlock(nil, [NSError errorWithDomain:SRGContentProtectionErrorDomain
                                                     code:SRGContentProtectionErrorCodeInvalidData
                                                 userInfo:@{ NSLocalizedDescriptionKey : SRGContentProtectionLocalizedString(@"The data is invalid.", @"The error message when the response from IL server is incorrect.") }]);
            return;
        }
        
        completionBlock(JSONDictionary, nil);
    }];
}

- (NSURLSessionTask *)synchronousDataRequest:(NSURLRequest *)request withCompletionBlock:(void (^)(NSData * _Nullable, NSError * _Nullable))completionBlock
{
    return [self asynchronousDataRequest:request withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(data, error);
        });
    }];
}

- (NSURLSessionTask *)synchronousJSONDictionaryRequest:(NSURLRequest *)request withCompletionBlock:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completionBlock
{
    return [self asynchronousJSONDictionaryRequest:request withCompletionBlock:^(NSDictionary * _Nullable JSONDictionary, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(JSONDictionary, error);
        });
    }];
}

@end
