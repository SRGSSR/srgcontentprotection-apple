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
 *  @discussion Medias with no content protection will be played as is. If the content is protected and the specified
 *              protection does not match, playback will fail.
 */
+ (instancetype)srg_assetWithURL:(NSURL *)URL contentProtection:(SRGContentProtection)contentProtection;

@end

NS_ASSUME_NONNULL_END
