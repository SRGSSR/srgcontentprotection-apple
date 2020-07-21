//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Use to avoid user-facing text analyzer warnings.
 *
 *  See https://clang-analyzer.llvm.org/faq.html.
 */
__attribute__((annotate("returns_localized_nsstring")))
OBJC_EXPORT NSString *SRGContentProtectionNonLocalizedString(NSString *string);


/**
 *  Convenience macro for localized strings associated with the framework.
 */
#define SRGContentProtectionLocalizedString(key, comment) [SWIFTPM_MODULE_BUNDLE localizedStringForKey:(key) value:@"" table:nil]

NS_ASSUME_NONNULL_END
