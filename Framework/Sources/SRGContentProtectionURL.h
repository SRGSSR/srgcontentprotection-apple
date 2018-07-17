//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionConstants.h"

NS_ASSUME_NONNULL_BEGIN

// To force an asset resource loader to be used (especially on foreign AirPlay receivers), we use a custom
// reserved scheme, for which the system cannot figure out what to do and is therefore forced to ask a resource
// loader delegate for help.

OBJC_EXPORT NSURL *SRGContentProtectionWrapURL(NSURL *URL, SRGContentProtection contentProtection);
OBJC_EXPORT NSURL * _Nullable SRGContentProtectionUnwrapURL(NSURL *URL, SRGContentProtection contentProtection);

NS_ASSUME_NONNULL_END
