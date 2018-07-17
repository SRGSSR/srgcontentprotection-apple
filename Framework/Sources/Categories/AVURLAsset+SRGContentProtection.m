//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AVURLAsset+SRGContentProtection.h"

#import "SRGAkamaiResourceLoaderDelegate.h"
#import "SRGFairPlayResourceLoaderDelegate.h"
#import "SRGContentProtectionURL.h"

#import <objc/runtime.h>

static void *SRGContentProtectionResourceLoaderDelegateKey = &SRGContentProtectionResourceLoaderDelegateKey;

static id<AVAssetResourceLoaderDelegate> SRGContentProtectionResourceLoaderDelegate(SRGContentProtection contentProtection)
{
    static dispatch_once_t s_onceToken;
    static NSDictionary<NSNumber *, Class> *s_resourceLoaderDelegateClasses;
    dispatch_once(&s_onceToken, ^{
        s_resourceLoaderDelegateClasses = @{ @(SRGContentProtectionAkamaiToken) : [SRGAkamaiResourceLoaderDelegate class],
                                             @(SRGContentProtectionFairPlay) : [SRGFairPlayResourceLoaderDelegate class] };
    });
    
    Class resourceLoaderDelegateClass = s_resourceLoaderDelegateClasses[@(contentProtection)];
    return [[resourceLoaderDelegateClass alloc] init];
}

@implementation AVURLAsset (SRGContentProtection)

+ (instancetype)srg_assetWithURL:(NSURL *)URL contentProtection:(SRGContentProtection)contentProtection
{
    NSURL *wrappedURL = SRGContentProtectionWrapURL(URL, contentProtection);
    AVURLAsset *asset = [AVURLAsset assetWithURL:wrappedURL];
    
    id<AVAssetResourceLoaderDelegate> resourceLoaderDelegate = SRGContentProtectionResourceLoaderDelegate(contentProtection);
    objc_setAssociatedObject(asset, SRGContentProtectionResourceLoaderDelegateKey, resourceLoaderDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    dispatch_queue_t queue = dispatch_queue_create("ch.srg.resourceLoader", DISPATCH_QUEUE_SERIAL);
    [asset.resourceLoader setDelegate:resourceLoaderDelegate queue:queue];
    
    return asset;
}

@end
