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

#pragma mark Class methods

+ (instancetype)srg_assetWithURL:(NSURL *)URL resourceLoaderDelegate:(id<SRGResourceLoaderDelegate>)resourceLoaderDelegate
{
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    objc_setAssociatedObject(asset, SRGContentProtectionResourceLoaderDelegateKey, resourceLoaderDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_queue_t queue = dispatch_queue_create("ch.srg.resourceLoader", DISPATCH_QUEUE_SERIAL);
    [asset.resourceLoader setDelegate:resourceLoaderDelegate queue:queue];
    
    return asset;
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL
{
    return [self srg_assetWithURL:URL licenseURL:nil];
}

+ (instancetype)srg_assetWithURL:(NSURL *)URL licenseURL:(NSURL *)licenseURL
{
    id<SRGResourceLoaderDelegate> resourceLoaderDelegate = licenseURL ? [[SRGFairPlayResourceLoaderDelegate alloc] initWithCertificateURL:licenseURL] : [[SRGAkamaiResourceLoaderDelegate alloc] init];
    NSURL *assetURL = [resourceLoaderDelegate respondsToSelector:@selector(assetURLForURL:)] ? [resourceLoaderDelegate assetURLForURL:URL] : URL;
    return [self srg_assetWithURL:assetURL resourceLoaderDelegate:resourceLoaderDelegate];
}

@end
