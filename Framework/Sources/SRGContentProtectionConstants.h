//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Content protection types.
 */
typedef NS_ENUM(NSInteger, SRGContentProtection) {
    /**
     *  Not specified.
     */
    SRGContentProtectionNone = 0,
    /**
     *  Free from any content protection mechanism.
     */
    SRGContentProtectionFree,
    /**
     *  Akamai token-based protection.
     */
    SRGContentProtectionAkamaiToken,
    /**
     *  FairPlay encryption.
     */
    SRGContentProtectionFairPlay
};

NS_ASSUME_NONNULL_END
