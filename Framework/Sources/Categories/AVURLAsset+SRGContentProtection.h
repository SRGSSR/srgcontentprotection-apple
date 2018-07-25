//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `AVURLAsset` extensions for protected content playback. To play a protected content:
 *    - Create an asset using the class method matching the content protection associated with the stream.
 *    - Instantiate an `AVPlayerItem` from this asset.
 *
 *  For non-protected content, you can simply use `+[AVURLAsset assetWithURL:]` or the convenience constructor
 *  `+[AVPlayerItem playerItemWithURL:` when creating the item.
 */
@interface AVURLAsset (SRGContentProtection)

/**
 *  Create an asset for an Akamai token-protected stream.
 *
 *  @param URL The Akamai URL to be played.
 *
 *  @discussion If the media is not protected with an Akamai token, the content might play, but this is not guaranteed.
 */
+ (instancetype)srg_akamaiTokenProtectedAssetWithURL:(NSURL *)URL;

/**
 *  Create an asset for a FairPlay-protected stream.
 *
 *  @param URL            The FairPlay protected stream URL to be played.
 *  @param certificateURL The URL at which the FairPlay certificate can be retrieved.
 *
 *  @discussion If the media is not protected with FairPlay, the content might play, but this is not guaranteed.
 */
+ (instancetype)srg_fairPlayProtectedAssetWithURL:(NSURL *)URL certificateURL:(NSURL *)certificateURL;

@end

NS_ASSUME_NONNULL_END
