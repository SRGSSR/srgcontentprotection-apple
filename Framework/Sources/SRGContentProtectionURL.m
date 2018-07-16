//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionURL.h"

static NSDictionary<NSNumber *, NSString *> *SRGContentProtectionBootstrapSchemePrefixes(void)
{
    static dispatch_once_t s_onceToken;
    static NSDictionary<NSNumber *, NSString *> *s_shemePrefixes;
    dispatch_once(&s_onceToken, ^{
        s_shemePrefixes = @{ @(SRGContentProtectionAkamaiToken) : @"akamai",
                             @(SRGContentProtectionAkamaiToken) : @"fairplay" };
    });
    return s_shemePrefixes;
}

NSURL *SRGContentProtectionWrapURL(NSURL *URL, SRGContentProtection contentProtection)
{
    NSString *schemePrefix = SRGContentProtectionBootstrapSchemePrefixes()[@(contentProtection)];
    if (! schemePrefix) {
        return URL;
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    components.scheme = [@[schemePrefix, components.scheme] componentsJoinedByString:@"+"];
    return components.URL;
}

NSURL *SRGContentProtectionUnwrapURL(NSURL *URL, SRGContentProtection contentProtection)
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    NSArray<NSString *> *schemeComponents = [components.scheme componentsSeparatedByString:@"+"];
    if (schemeComponents.count != 2) {
        return URL;
    }
    
    NSNumber *contentProtectionNumber = [SRGContentProtectionBootstrapSchemePrefixes() allKeysForObject:schemeComponents.firstObject].firstObject;
    if (! contentProtectionNumber || contentProtectionNumber.integerValue != contentProtection) {
        return nil;
    }
    
    components.scheme = schemeComponents.lastObject;
    return components.URL;
}
