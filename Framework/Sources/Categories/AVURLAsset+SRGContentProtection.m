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

+ (instancetype)srg_assetWithURL:(NSURL *)URL options:(NSDictionary<SRGAssetOption,id> *)options
{
    return [self srg_assetWithURL:URL certificateURL:nil options:options];
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL
{
    return [self srg_assetWithURL:URL];
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL certificateURL:(NSURL *)certificateURL options:(NSDictionary<SRGAssetOption,id> *)options
{
    SRGAssetResourceLoaderDelegate *resourceLoaderDelegate = nil;
    if (certificateURL) {
        resourceLoaderDelegate = [[SRGFairPlayAssetResourceLoaderDelegate alloc] initWithCertificateURL:certificateURL];
    }
    else if ([URL.host containsString:@"akamai"] && [URL.path.pathExtension isEqualToString:@"m3u8"]) {
        resourceLoaderDelegate = [[SRGAkamaiAssetResourceLoaderDelegate alloc] init];
    }
    resourceLoaderDelegate.options = options;
    
    return [self srg_assetWithURL:URL resourceLoaderDelegate:resourceLoaderDelegate];
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL certificateURL:(NSURL *)certificateURL
{
    return [self srg_assetWithURL:URL certificateURL:certificateURL options:nil];
}

@end
