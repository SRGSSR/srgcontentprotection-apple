//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPURLResponse (SRGContentProtection)

/**
 *  Returns a capitalized localized string for the specified HTTP status code.
 *
 *  @discussion This method is a fix for the buggy +localizedStringForStatusCode: public method. See
 *                http://openradar.appspot.com/radar?id=5498641225613312.
 */
+ (NSString *)srg_contentProtection_localizedStringForStatusCode:(NSInteger)statusCode;

@end

NS_ASSUME_NONNULL_END
