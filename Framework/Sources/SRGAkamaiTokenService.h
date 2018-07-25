//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <SRGNetwork/SRGNetwork.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Akamai token generation service.
 */
@interface SRGAkamaiTokenService : NSObject

/**
 *  Service singleton instance.
 */
+ (instancetype)sharedService;

/**
 *  Return a network request for retrieving an Akamai token for the specified URL. Except in special cases where
 *  you need to provide the URL to another context (e.g. Google Cast), there is in general no need for explicit
 *  tokenization in client code. When preparing an item for `AVPlayer` playback, build your asset using the
 *  `+[AVURLAsset srg_assetWithURL:contentProtection:]` method instead.
 *
 *  @discussion If the request fails, the original URL is returned in the completion block and can be used to attempt
 *              playback (without guarantee that this will succeed, though).
 */
- (SRGNetworkRequest *)tokenizeURL:(NSURL *)URL withCompletionBlock:(void (^)(NSURL *URL))completionBlock;

@end

NS_ASSUME_NONNULL_END
