//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSBundle+SRGContentProtection.h"

#import "SRGAkamaiResourceLoaderDelegate.h"

@implementation NSBundle (SRGLetterbox)

#pragma mark Class methods

+ (instancetype)srg_contentProtectionBundle
{
    static NSBundle *bundle;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        bundle = [NSBundle bundleForClass:[SRGAkamaiResourceLoaderDelegate class]];
    });
    return bundle;
}

@end
