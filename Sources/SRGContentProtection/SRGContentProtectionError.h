//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Content protection error constants.
 */
typedef NS_ENUM(NSInteger, SRGContentProtectionErrorCode) {
    /**
     *  Authorization to play a protected stream could not be retrieved.
     */
    SRGContentProtectionErrorUnauthorized
};

/**
 *  Common domain for content protection errors.
 */
OBJC_EXPORT NSString * const SRGContentProtectionErrorDomain;

NS_ASSUME_NONNULL_END
