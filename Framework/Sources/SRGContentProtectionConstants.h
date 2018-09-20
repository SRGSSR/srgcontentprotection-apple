//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

/**
 *  Options for asset playback.
 */
typedef NSString * SRGAssetOption NS_TYPED_ENUM;

/**
 *  The diagnostics service which internal information should be sent to. If omitted, no diagnostic information will be
 *  generated.
 */
OBJC_EXPORT NSString * const SRGAssetOptionDiagnosticServiceNameKey;

/**
 *  The name of the diagnostic report to associate information with. If omitted, no diagnostic information will be
 *  generated.
 */
OBJC_EXPORT NSString * const SRGAssetOptionDiagnosticReportNameKey;
