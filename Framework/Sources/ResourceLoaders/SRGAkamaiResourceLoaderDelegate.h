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

- (instancetype)initWithURL:(NSURL *)URL NS_DESIGNATED_INITIALIZER;

@end

@interface SRGAkamaiResourceLoaderDelegate (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
