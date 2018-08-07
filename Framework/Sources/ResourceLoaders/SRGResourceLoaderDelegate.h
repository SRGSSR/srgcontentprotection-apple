//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Resource loader delegate protocol.
 */
@protocol SRGResourceLoaderDelegate <AVAssetResourceLoaderDelegate>

@optional

/**
 *  Return the asset URL to use for a given URL. If not implemented, the original URL will be used.
 */
- (NSURL *)assetURLForURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
