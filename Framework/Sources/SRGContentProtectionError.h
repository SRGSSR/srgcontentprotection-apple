//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Content protection error constants. More information is available from the `userInfo` associated with these errors.
 */
typedef NS_ENUM(NSInteger, SRGContentProtectionErrorCode) {
    /**
     *  An HTTP error has been encountered. The HTTP status code is available from the user info under the
     *  `SRGContentProtectionHTTPStatusCodeKey` key (as an `NSNumber`).
     */
    SRGContentProtectionErrorHTTP,
    /**
     *  A redirect was encountered. This is e.g. often encountered on public wifis with a login page. Use the 
     *  `SRGContentProtectionRedirectionURLKey` info key to retrieve the redirection URL (as an `NSURL`).
     */
    SRGContentProtectionErrorRedirect,
    /**
     *  The data which was received is invalid.
     */
    SRGContentProtectionErrorCodeInvalidData,
    /**
     *  Digital rights could not be obtained.
     */
    SRGContentProtectionErrorCodeDigitalRights
};

/**
 *  Common domain for content protection errors.
 */
OBJC_EXPORT NSString * const SRGContentProtectionErrorDomain;

/**
 *  Error user information keys, @see `SRGContentProtectionErrorCode`.
 */
OBJC_EXPORT NSString * const SRGContentProtectionHTTPStatusCodeKey;
OBJC_EXPORT NSString * const SRGContentProtectionRedirectionURLKey;

NS_ASSUME_NONNULL_END
