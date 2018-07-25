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

+ (instancetype)srg_assetWithURL:(NSURL *)URL resourceLoaderDelegate:(id<AVAssetResourceLoaderDelegate>)resourceLoaderDelegate
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    objc_setAssociatedObject(asset, SRGContentProtectionResourceLoaderDelegateKey, resourceLoaderDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_queue_t queue = dispatch_queue_create("ch.srg.resourceLoader", DISPATCH_QUEUE_SERIAL);
    [asset.resourceLoader setDelegate:resourceLoaderDelegate queue:queue];
    
    return asset;
}

+ (instancetype)srg_akamaiTokenProtectedAssetWithURL:(NSURL *)URL
{
    id<AVAssetResourceLoaderDelegate> resourceLoaderDelegate = [[SRGAkamaiResourceLoaderDelegate alloc] init];
    return [self srg_assetWithURL:[SRGAkamaiResourceLoaderDelegate assetURLForURL:URL] resourceLoaderDelegate:resourceLoaderDelegate];
}

+ (instancetype)srg_fairPlayProtectedAssetWithURL:(NSURL *)URL certificateURL:(NSURL *)certificateURL
{
    id<AVAssetResourceLoaderDelegate> resourceLoaderDelegate = [[SRGFairPlayResourceLoaderDelegate alloc] initWithCertificateURL:certificateURL];
    return [self srg_assetWithURL:URL resourceLoaderDelegate:resourceLoaderDelegate];
}

@end
