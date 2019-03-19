//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

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
#define SRGContentProtectionLocalizedString(key, comment) [NSBundle.srg_contentProtectionBundle localizedStringForKey:(key) value:@"" table:nil]

@interface NSBundle (SRGContentProtection)

/**
 *  The framework resource bundle.
 */
@property (class, nonatomic, readonly) NSBundle *srg_contentProtectionBundle;

@end

NS_ASSUME_NONNULL_END
