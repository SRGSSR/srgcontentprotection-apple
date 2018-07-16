//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionConstants.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXPORT NSURL *SRGContentProtectionWrapURL(NSURL *URL, SRGContentProtection contentProtection);
OBJC_EXPORT NSURL * _Nullable SRGContentProtectionUnwrapURL(NSURL *URL, SRGContentProtection contentProtection);

NS_ASSUME_NONNULL_END
