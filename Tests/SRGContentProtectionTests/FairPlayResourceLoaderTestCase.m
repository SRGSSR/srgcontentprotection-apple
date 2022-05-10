//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import AVFoundation;
@import SRGContentProtection;
@import XCTest;

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

- (void)testProtectedResourcePlaybackWithParameter
{
    // Cannot be tested in the simulator, works only on a device
}

- (void)testNonProtectedResourcePlayback
{
    NSURL *URL = [NSURL URLWithString:@"https://rtsc3video-lh.akamaihd.net/i/rtsc3video_ww@513975/master.m3u8"];
    AVURLAsset *asset = [AVURLAsset srg_fairPlayProtectedAssetWithURL:URL certificateURL:FairPlayCertificateURL() options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

- (void)testNonProtectedResourcePlaybackWithParameter
{
    NSURL *URL = [NSURL URLWithString:@"https://rtsc3video-lh.akamaihd.net/i/rtsc3video_ww@513975/master.m3u8?__b__=800"];
    AVURLAsset *asset = [AVURLAsset srg_fairPlayProtectedAssetWithURL:URL certificateURL:FairPlayCertificateURL() options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

- (void)testInvalidResourcePlayback
{
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/status/404"];
    AVURLAsset *asset = [AVURLAsset srg_fairPlayProtectedAssetWithURL:URL certificateURL:FairPlayCertificateURL() options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusFailed)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

- (void)testAkamaiMP3ResourcePlayback
{
    NSURL *URL = [NSURL URLWithString:@"https://srfaudio-a.akamaihd.net/delivery/world/75f44907-4638-422d-bc80-bbb14c9d9c93.mp3"];
    AVURLAsset *asset = [AVURLAsset srg_fairPlayProtectedAssetWithURL:URL certificateURL:FairPlayCertificateURL() options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

@end
