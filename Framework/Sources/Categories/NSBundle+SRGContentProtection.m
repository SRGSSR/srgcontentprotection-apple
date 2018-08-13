//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSBundle+SRGContentProtection.h"

#import "SRGAkamaiAssetResourceLoaderDelegate.h"

@implementation NSBundle (SRGContentProtection)

#pragma mark Class methods

+ (instancetype)srg_contentProtectionBundle
{
    static NSBundle *s_bundle;
    static dispatch_once_t s_once;
    dispatch_once(&s_once, ^{
        NSString *bundlePath = [[NSBundle bundleForClass:[SRGAkamaiAssetResourceLoaderDelegate class]].bundlePath stringByAppendingPathComponent:@"SRGContentProtection.bundle"];
        s_bundle = [NSBundle bundleWithPath:bundlePath];
        NSAssert(s_bundle, @"Please add SRGContentProtection.bundle to your project resources");
    });
    return s_bundle;
}

@end
