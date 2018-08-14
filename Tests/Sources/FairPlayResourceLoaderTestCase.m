//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <AVFoundation/AVFoundation.h>
#import <SRGContentProtection/SRGContentProtection.h>
#import <XCTest/XCTest.h>

static NSURL *FairPlayCertificateURL(void)
{
    return [NSURL URLWithString:@"https://rng.stage.ott.irdeto.com/licenseServer/streaming/v1/SRG/getcertificate?applicationId=stage"];
}

@interface FairPlayResourceLoaderTestCase : XCTestCase

@property (nonatomic) AVPlayer *player;

@end

@implementation FairPlayResourceLoaderTestCase

#pragma mark Tests

- (void)testProtectedResourcePlayback
{
    // Cannot be tested in the simulator, works only on a device
}

- (void)testNonProtectedResourcePlayback
{
    AVURLAsset *asset = [AVURLAsset srg_assetWithURL:[NSURL URLWithString:@"http://tagesschau-lh.akamaihd.net/i/tagesschau_1@119231/master.m3u8"]
                                          licenseURL:FairPlayCertificateURL()];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

- (void)testInvalidResourcePlayback
{
    AVURLAsset *asset = [AVURLAsset srg_assetWithURL:[NSURL URLWithString:@"http://httpbin.org/status/404"]
                                          licenseURL:FairPlayCertificateURL()];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusFailed)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:10. handler:nil];
}

@end
