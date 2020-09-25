//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

/**
 *  Options applied when loading a resource.
 */
typedef NSString * SRGResourceLoaderOption NS_TYPED_ENUM;

/**
 *  The diagnostics service which internal information should be sent to. If omitted, no diagnostic information will be
 *  generated when loading the resource.
 */
OBJC_EXPORT NSString * const SRGResourceLoaderOptionDiagnosticServiceNameKey;

/**
 *  The name of the diagnostic report to associate information with. If omitted, no diagnostic information will be
 *  generated when loading the resource.
 */
OBJC_EXPORT NSString * const SRGResourceLoaderOptionDiagnosticReportNameKey;
