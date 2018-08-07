//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `AVURLAsset` extensions for protected content playback. To play a protected content:
 *    - Create an asset using the `+srg_assetWithURL:certificateURL:` method.
 *    - Instantiate an `AVPlayerItem` from this asset.
 *
 *  For non-protected content, you can simply use `+[AVURLAsset assetWithURL:]` or the convenience constructor
 *  `+[AVPlayerItem playerItemWithURL:]` when creating the item.
 */
@interface AVURLAsset (SRGContentProtection)

/**
 *  Create an asset supporting standard SRG SSR content protection.
 *
 *  @param URL The URL to be played.
 */
+ (instancetype)srg_assetWithURL:(NSURL *)URL;

/**
 *  Create an asset supporting standard SRG SSR content protection. Digital rights management can optionally be enabled
 *  by supplying a URL to retrieve licenses from.
 *
 *  @param URL        The URL to be played.
 *  @param licenseURL The URL where licenses must be retrieved.
 */
+ (instancetype)srg_assetWithURL:(NSURL *)URL licenseURL:(nullable NSURL *)licenseURL;

@end

NS_ASSUME_NONNULL_END
