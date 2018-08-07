//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGAssetResourceLoaderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Resource loader delegate for streams encrypted with FairPlay.
 */
@interface SRGFairPlayAssetResourceLoaderDelegate : NSObject <SRGAssetResourceLoaderDelegate>

/**
 *  Create an instance retrieving certificates at the specified URL.
 */
- (instancetype)initWithCertificateURL:(NSURL *)certificateURL NS_DESIGNATED_INITIALIZER;

@end

@interface SRGFairPlayAssetResourceLoaderDelegate (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
