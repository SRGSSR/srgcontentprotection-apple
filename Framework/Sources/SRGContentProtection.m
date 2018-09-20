//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtection.h"

#import "NSBundle+SRGContentProtection.h"

NSString *SRGContentProtectionMarketingVersion(void)
{
    return NSBundle.srg_contentProtectionBundle.infoDictionary[@"CFBundleShortVersionString"];
}

BOOL SRGContentProtectionIsPublic(void)
{
    return NO;
}
