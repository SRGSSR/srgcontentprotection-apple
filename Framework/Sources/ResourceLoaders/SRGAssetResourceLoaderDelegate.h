//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGContentProtectionConstants.h"

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Resource loader abstract base class.
 */
@interface SRGAssetResourceLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

/**
 *  Suclasses can override this method to return another URL to use for a given URL. The default implementation returns
 *  the original URL received as parameter.
 */
- (NSURL *)assetURLForURL:(NSURL *)URL;

/**
 *  Subclasses must override this method to process the loading request appropriately. The default implementation does
 *  nothing and returns `NO`.
 */
- (BOOL)shouldProcessResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest;

/**
 *  Subclasses must override this method to respond to a resource having been cancelled. The default implementation does
 *  nothing.
 */
- (void)didCancelResourceLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest;

/**
 *  Optional information associated with the receiver.
 */
@property (nonatomic, nullable) NSDictionary<SRGAssetOption, id> *options;

@end

NS_ASSUME_NONNULL_END
