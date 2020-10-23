//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface Media : NSObject

+ (NSArray<Media *> *)mediasFromFileAtPath:(NSString *)filePath;

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly, nullable) NSURL *certificateURL;

@end

NS_ASSUME_NONNULL_END
