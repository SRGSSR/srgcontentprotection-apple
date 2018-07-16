//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AVAsset+SRGContentProtection.h"

#import "SRGContentProtectionURL.h"

@implementation AVAsset (SRGContentProtection)

+ (instancetype)srg_assetWithURL:(NSURL *)URL contentProtection:(SRGContentProtection)contentProtection
{
    // To force an asset resource loader to be used (especially on foreign AirPlay receivers), we use a custom
    // reserved scheme, for which the player is forced to check its associated resource loader delegate.
    NSURL *bootstrapURL = SRGContentProtectionWrapURL(URL, contentProtection);
    return [AVAsset assetWithURL:bootstrapURL];
}

@end
