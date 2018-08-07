//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGResourceLoaderDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Resource loader delegate for streams encrypted with FairPlay.
 */
@interface SRGFairPlayResourceLoaderDelegate : NSObject <SRGResourceLoaderDelegate>

/**
 *  Create an instance retrieving certificates at the specified URL.
 */
- (instancetype)initWithCertificateURL:(NSURL *)certificateURL NS_DESIGNATED_INITIALIZER;

@end

@interface SRGFairPlayResourceLoaderDelegate (Unavailable)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
