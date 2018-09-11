//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AVURLAsset+SRGContentProtection.h"

#import "SRGAkamaiAssetResourceLoaderDelegate.h"
#import "SRGFairPlayAssetResourceLoaderDelegate.h"

#import <objc/runtime.h>

NSString * const SRGContentProtectionURNKey = @"SRGContentProtectionURN";

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

+ (instancetype)srg_assetWithURL:(NSURL *)URL userInfo:(NSDictionary *)userInfo
{
    return [self srg_assetWithURL:URL licenseURL:nil userInfo:userInfo];
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL
{
    return [self srg_assetWithURL:URL];
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL licenseURL:(NSURL *)licenseURL userInfo:(NSDictionary *)userInfo
{
    SRGAssetResourceLoaderDelegate *resourceLoaderDelegate = nil;
    if (licenseURL) {
        resourceLoaderDelegate = [[SRGFairPlayAssetResourceLoaderDelegate alloc] initWithCertificateURL:licenseURL];
    }
    else if ([URL.host containsString:@"akamai"] && [URL.path.pathExtension isEqualToString:@"m3u8"]) {
        resourceLoaderDelegate = [[SRGAkamaiAssetResourceLoaderDelegate alloc] init];
    }
    resourceLoaderDelegate.userInfo = userInfo;
    
    return [self srg_assetWithURL:URL resourceLoaderDelegate:resourceLoaderDelegate];
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL licenseURL:(NSURL *)licenseURL
{
    return [self srg_assetWithURL:URL licenseURL:licenseURL userInfo:nil];
}

@end
