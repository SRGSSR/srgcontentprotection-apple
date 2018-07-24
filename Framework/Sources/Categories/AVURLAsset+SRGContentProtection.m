//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AVURLAsset+SRGContentProtection.h"

#import "SRGAkamaiResourceLoaderDelegate.h"
#import "SRGFairPlayResourceLoaderDelegate.h"

#import <objc/runtime.h>

static void *SRGContentProtectionResourceLoaderDelegateKey = &SRGContentProtectionResourceLoaderDelegateKey;

@implementation AVURLAsset (SRGContentProtection)

+ (instancetype)srg_assetWithURL:(NSURL *)URL contentProtection:(SRGContentProtection)contentProtection
{
    AVURLAsset *asset = nil;
    id<AVAssetResourceLoaderDelegate> resourceLoaderDelegate = nil;
    
    switch (contentProtection) {
        case SRGContentProtectionAkamaiToken: {
            URL = [SRGAkamaiResourceLoaderDelegate assetURLForURL:URL];
            resourceLoaderDelegate = [[SRGAkamaiResourceLoaderDelegate alloc] init];
            break;
        }
            
        case SRGContentProtectionFairPlay: {
            resourceLoaderDelegate = [[SRGFairPlayResourceLoaderDelegate alloc] init];
            break;
        }
            
        case SRGContentProtectionNone: {
            break;
        }
    }
    
    asset = [AVURLAsset assetWithURL:URL];
    objc_setAssociatedObject(asset, SRGContentProtectionResourceLoaderDelegateKey, resourceLoaderDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_queue_t queue = dispatch_queue_create("ch.srg.resourceLoader", DISPATCH_QUEUE_SERIAL);
    [asset.resourceLoader setDelegate:resourceLoaderDelegate queue:queue];
    
    return asset;
}

@end
