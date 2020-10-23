//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionConstants.h"

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `AVURLAsset` extensions for protected content playback. To play a protected content:
 *    - Create an asset using the one of the supplied class methods, depending on the kind of protection required.
 *    - Instantiate an `AVPlayerItem` from this asset.
 *
 *  For non-protected content, you can simply use `+[AVURLAsset assetWithURL:]` or the convenience constructor
 *  `+[AVPlayerItem playerItemWithURL:]` when creating the item.
 *
 *  If the protection used does not match the one required by the content, playback will likely fail.
 */
@interface AVURLAsset (SRGContentProtection)

/**
 *  Create an asset supporting Akamai SRG SSR content protection.
 *
 *  @param URL     The URL to be played.
 *  @param options Options to be applied when loading the resource.
 */
+ (instancetype)srg_akamaiTokenProtectedAssetWithURL:(NSURL *)URL options:(nullable NSDictionary<SRGResourceLoaderOption, id> *)options;

/**
 *  Create an asset supporting FairPlay SRG SSR content protection.
 *
 *  @param URL            The URL to be played.
 *  @param certificateURL The URL where the certificate must be retrieved.
 *  @param options Options to be applied when loading the resource.
 */
+ (instancetype)srg_fairPlayProtectedAssetWithURL:(NSURL *)URL certificateURL:(NSURL *)certificateURL options:(nullable NSDictionary<SRGResourceLoaderOption, id> *)options;

@end

NS_ASSUME_NONNULL_END
