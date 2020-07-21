//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AVURLAsset+SRGContentProtection.h"

#import "SRGAkamaiAssetResourceLoaderDelegate.h"
#import "SRGFairPlayAssetResourceLoaderDelegate.h"

#import <objc/runtime.h>

static void *SRGContentProtectionResourceLoaderDelegateKey = &SRGContentProtectionResourceLoaderDelegateKey;

@implementation AVURLAsset (SRGContentProtection)

#pragma mark Class methods

+ (instancetype)srg_assetWithURL:(NSURL *)URL resourceLoaderDelegate:(SRGAssetResourceLoaderDelegate *)resourceLoaderDelegate
{
    NSURL *assetURL = resourceLoaderDelegate ? [resourceLoaderDelegate assetURLForURL:URL] : URL;
    AVURLAsset *asset = [AVURLAsset assetWithURL:assetURL];
    objc_setAssociatedObject(asset, SRGContentProtectionResourceLoaderDelegateKey, resourceLoaderDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_queue_t queue = dispatch_queue_create("ch.srg.resourceLoader", DISPATCH_QUEUE_SERIAL);
    [asset.resourceLoader setDelegate:resourceLoaderDelegate queue:queue];
    
    return asset;
}

+ (instancetype)srg_akamaiTokenProtectedAssetWithURL:(NSURL *)URL options:(NSDictionary<SRGResourceLoaderOption,id> *)options
{
    SRGAssetResourceLoaderDelegate *resourceLoaderDelegate = [[SRGAkamaiAssetResourceLoaderDelegate alloc] init];
    resourceLoaderDelegate.options = options;
    return [self srg_assetWithURL:URL resourceLoaderDelegate:resourceLoaderDelegate];
}

+ (instancetype)srg_fairPlayProtectedAssetWithURL:(NSURL *)URL certificateURL:(NSURL *)certificateURL options:(NSDictionary<SRGResourceLoaderOption,id> *)options
{
    SRGAssetResourceLoaderDelegate *resourceLoaderDelegate = [[SRGFairPlayAssetResourceLoaderDelegate alloc] initWithCertificateURL:certificateURL];
    resourceLoaderDelegate.options = options;
    return [self srg_assetWithURL:URL resourceLoaderDelegate:resourceLoaderDelegate];
}

@end
