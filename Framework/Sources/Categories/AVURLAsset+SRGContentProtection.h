//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionConstants.h"

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVURLAsset (SRGContentProtection)

+ (instancetype)srg_assetWithURL:(NSURL *)URL contentProtection:(SRGContentProtection)contentProtection;

@end

NS_ASSUME_NONNULL_END
