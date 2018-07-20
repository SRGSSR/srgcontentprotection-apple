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
            // Use non-standard scheme unkwown to AirPlay receivers like the Apple TV. This ensures that the resource
            // loader delegate is used (if the resource is simply an HTTP one, the receiver thinks it can handle it,
            // and does not call the resource loader delegate).
            asset = [AVURLAsset assetWithURL:[NSURL URLWithString:@"akamai://media"]];
            resourceLoaderDelegate = [[SRGAkamaiResourceLoaderDelegate alloc] initWithURL:URL];
            break;
        }
            
        case SRGContentProtectionFairPlay: {
            asset = [AVURLAsset assetWithURL:URL];
            resourceLoaderDelegate = [[SRGFairPlayResourceLoaderDelegate alloc] init];
            break;
        }
            
        case SRGContentProtectionNone: {
            asset = [AVURLAsset assetWithURL:URL];
            break;
        }
    }
    
    objc_setAssociatedObject(asset, SRGContentProtectionResourceLoaderDelegateKey, resourceLoaderDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_queue_t queue = dispatch_queue_create("ch.srg.resourceLoader", DISPATCH_QUEUE_SERIAL);
    [asset.resourceLoader setDelegate:resourceLoaderDelegate queue:queue];
    
    return asset;
}

@end
