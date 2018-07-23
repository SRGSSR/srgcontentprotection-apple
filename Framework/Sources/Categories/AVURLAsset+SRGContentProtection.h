//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionConstants.h"

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `AVURLAsset` extensions.
 */
@interface AVURLAsset (SRGContentProtection)

/**
 *  Create an asset for playback, playing it using the specified content protection.
 *
 *  @discussion If the content protection does not match the one of the media, the content might play, but this is not
 *              guaranteed.
 */
+ (instancetype)srg_assetWithURL:(NSURL *)URL contentProtection:(SRGContentProtection)contentProtection;

@end

NS_ASSUME_NONNULL_END
