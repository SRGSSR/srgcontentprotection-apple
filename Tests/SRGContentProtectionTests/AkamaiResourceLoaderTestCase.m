//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import AVFoundation;
@import SRGContentProtection;
@import XCTest;

@interface AkamaiResourceLoaderTestCase : XCTestCase

@property (nonatomic) AVPlayer *player;

@end

@implementation AkamaiResourceLoaderTestCase

#pragma mark Tests

- (void)testProtectedResourcePlayback
{
    NSURL *URL = [NSURL URLWithString:@"https://srgssruni11ch-lh.akamaihd.net/i/enc11uni_ch@191455/master.m3u8"];
    AVURLAsset *asset = [AVURLAsset srg_akamaiTokenProtectedAssetWithURL:URL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

- (void)testProtectedResourcePlaybackWithParameter
{
    NSURL *URL = [NSURL URLWithString:@"https://srgssruni11ch-lh.akamaihd.net/i/enc11uni_ch@191455/master.m3u8?__b__=800"];
    AVURLAsset *asset = [AVURLAsset srg_akamaiTokenProtectedAssetWithURL:URL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

- (void)testNonProtectedResourcePlayback
{
    NSURL *URL = [NSURL URLWithString:@"https://rtsc3video-lh.akamaihd.net/i/rtsc3video_ww@513975/master.m3u8"];
    AVURLAsset *asset = [AVURLAsset srg_akamaiTokenProtectedAssetWithURL:URL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

- (void)testNonProtectedResourcePlaybackWithParameter
{
    NSURL *URL = [NSURL URLWithString:@"https://rtsc3video-lh.akamaihd.net/i/rtsc3video_ww@513975/master.m3u8?__b__=800"];
    AVURLAsset *asset = [AVURLAsset srg_akamaiTokenProtectedAssetWithURL:URL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusReadyToPlay)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

- (void)testInvalidResourcePlayback
{
    NSURL *URL = [NSURL URLWithString:@"http://httpbin.org/status/404"];
    AVURLAsset *asset = [AVURLAsset srg_akamaiTokenProtectedAssetWithURL:URL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    [self keyValueObservingExpectationForObject:playerItem keyPath:@"status" expectedValue:@(AVPlayerItemStatusFailed)];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self waitForExpectationsWithTimeout:20. handler:nil];
}

@end
