//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <SRGNetwork/SRGNetwork.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Akamai token generation.
 */
@interface SRGAkamaiToken : NSObject

/**
 *  Return a network request for retrieving an Akamai token for the specified URL. Except in special cases where
 *  you need to provide the URL to another context (e.g. Google Cast), there is in general no need for explicit
 *  tokenization in client code. When preparing an item for `AVPlayer` playback, build your asset using the
 *  methods from the `AVURLAsset (SRGContentProtection)` category instead.
 *
 *  @param URL             The Akamai URL to tokenize.
 *  @param session         The session for which the request is executed.
 *  @param completionBlock The block to be called on completion.
 *
 *  @discussion If the request fails, the original URL is returned in the completion block and can be used to attempt
 *              playback (without guarantee that this will succeed, though). If the specified URL is not an Akamai
 *              URL, attempting to play the returned URL leads to undefined behavior (it might play or not).
 */
+ (SRGNetworkRequest *)tokenizeURL:(NSURL *)URL withSession:(NSURLSession *)session completionBlock:(void (^)(NSURL *URL))completionBlock;

@end

NS_ASSUME_NONNULL_END