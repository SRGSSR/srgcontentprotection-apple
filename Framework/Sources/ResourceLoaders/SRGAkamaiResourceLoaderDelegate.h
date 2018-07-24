//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Resource loader delegate for Akamai token-protected streams.
 */
@interface SRGAkamaiResourceLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

/**
 *  Return the asset URL to be played for playback using the Akamai resource loader delegate.
 */
+ (NSURL *)assetURLForURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
