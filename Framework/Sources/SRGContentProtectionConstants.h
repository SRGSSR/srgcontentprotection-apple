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
     *  No content protection.
     */
    SRGContentProtectionNone = 0,
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
