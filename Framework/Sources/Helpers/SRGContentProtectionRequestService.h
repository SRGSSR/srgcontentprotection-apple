//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// TODO: The following code is currently duplicated with SRG Data Provider, but will be common when SRGNetwork is introduced.
//       Factoring it out now would be premature.
@interface SRGContentProtectionRequestService : NSObject

+ (instancetype)sharedService;

- (NSURLSessionTask *)asynchronousDataRequest:(NSURLRequest *)request withCompletionBlock:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionBlock;
- (NSURLSessionTask *)asynchronousJSONDictionaryRequest:(NSURLRequest *)request withCompletionBlock:(void (^)(NSDictionary * _Nullable JSONDictionary, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
