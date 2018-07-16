//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSHTTPURLResponse+SRGContentProtection.h"

@implementation NSHTTPURLResponse (SRGContentProtection)

// TODO: Remove this workaround when the bug has been fixed on all supported iOS versions
+ (NSString *)srg_contentProtection_localizedStringForStatusCode:(NSInteger)statusCode
{
    // The +localizedStringForStatusCode: method always returns the English version, which we use as localization key
    NSString *localizationKey = [self localizedStringForStatusCode:statusCode];
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *localizedString = [bundle localizedStringForKey:localizationKey value:localizationKey table:nil];
    NSString *capitalizedFirstLetter = [[localizedString substringToIndex:1] uppercaseStringWithLocale:[NSLocale currentLocale]];
    return [localizedString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:capitalizedFirstLetter];
}

@end
