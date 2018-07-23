//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DemosViewController.h"

#import <AVKit/AVKit.h>
#import <SRGContentProtection/SRGContentProtection.h>

@interface DemosViewController ()

@end

@implementation DemosViewController

#pragma mark Object lifecycle

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self.class) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

#pragma mark Getters and setters

- (NSString *)title
{
    return NSLocalizedString(@"Demos", nil);
}

#pragma mark UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static dispatch_once_t s_onceToken;
    static NSDictionary<NSNumber *, NSURL *> *s_URLs;
    dispatch_once(&s_onceToken, ^{
        s_URLs = @{ @0 : [NSURL URLWithString:@"https://rtsvodww-vh.akamaihd.net/i/genhi/2018/genhi_20180126_full_f_1067247-,301k,101k,701k,1201k,2001k,fra-ad,.mp4.csmil/master.m3u8"],
                    @1 : [NSURL URLWithString:@"https://srgssruni9ch-lh.akamaihd.net/i/enc9uni_ch@191320/master.m3u8"],
                    @2 : [NSURL URLWithString:@"https://accountdigitalinnovation.streaming.mediaservices.windows.net/7e157f65-a8a0-4810-897c-fcc49c946a1c/bbd11abe-936f-4b71-ae4c-6d651d86e6b0.ism/manifest(format=m3u8-aapl)"],
                    @3 : [NSURL URLWithString:@"https://lsaplus.swisstxt.ch/audio/la-1ere_96.stream/playlist.m3u8"] };
    });
    
    NSURL *URL = s_URLs[@(indexPath.row)];
    
    AVURLAsset *asset = nil;
    switch (indexPath.section) {
        case 0: {
            asset = [AVURLAsset srg_assetWithURL:URL contentProtection:SRGContentProtectionNone];
            break;
        }
            
        case 1: {
            asset = [AVURLAsset srg_assetWithURL:URL contentProtection:SRGContentProtectionAkamaiToken];
            break;
        }
            
        case 2: {
            asset = [AVURLAsset srg_assetWithURL:URL contentProtection:SRGContentProtectionFairPlay];
            break;
        }
            
        default: {
            break;
        }
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
    
    [self presentViewController:playerViewController animated:YES completion:^{
        [player play];
    }];
}

@end
