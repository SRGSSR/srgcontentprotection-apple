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
    static NSBundle *bundle;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        bundle = [NSBundle bundleForClass:[SRGAkamaiAssetResourceLoaderDelegate class]];
    });
    return bundle;
}

@end
