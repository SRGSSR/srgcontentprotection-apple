//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionURL.h"

static NSDictionary<NSNumber *, NSString *> *SRGContentProtectionRoutingPrefixes(void)
{
    static dispatch_once_t s_onceToken;
    static NSDictionary<NSNumber *, NSString *> *s_routingPrefixes;
    dispatch_once(&s_onceToken, ^{
        s_routingPrefixes = @{ @(SRGContentProtectionAkamaiToken) : @"akamai",
                               @(SRGContentProtectionAkamaiToken) : @"fairplay" };
    });
    return s_routingPrefixes;
}

NSURL *SRGContentProtectionRoutingURL(NSURL *URL, SRGContentProtection contentProtection)
{
    NSString *routingPrefix = SRGContentProtectionRoutingPrefixes()[@(contentProtection)];
    if (! routingPrefix) {
        return URL;
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    components.scheme = [@[routingPrefix, components.scheme] componentsJoinedByString:@"+"];
    return components.URL;
}

NSURL *SRGContentProtectionRoutedURL(NSURL *routingURL, SRGContentProtection contentProtection)
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:routingURL resolvingAgainstBaseURL:NO];
    NSArray<NSString *> *schemeComponents = [components.scheme componentsSeparatedByString:@"+"];
    if (schemeComponents.count != 2) {
        return routingURL;
    }
    
    NSNumber *contentProtectionNumber = [SRGContentProtectionRoutingPrefixes() allKeysForObject:schemeComponents.firstObject].firstObject;
    if (! contentProtectionNumber || contentProtectionNumber.integerValue != contentProtection) {
        return nil;
    }
    
    components.scheme = schemeComponents.lastObject;
    return components.URL;
}
