//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "TVDemosViewController.h"

#import <AVKit/AVKit.h>
#import <SRGContentProtection/SRGContentProtection.h>

@implementation TVDemosViewController

#pragma mark Object lifecycle

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(self.class) bundle:nil];
    TVDemosViewController *viewController = [storyboard instantiateInitialViewController];
    viewController.tableView.remembersLastFocusedIndexPath = YES;
    return viewController;
}

#pragma mark Getters and setters

- (NSString *)title
{
    return NSLocalizedString(@"Demos", nil);
}

- (NSString *)titleForSection:(NSInteger)section
{
    static dispatch_once_t s_onceToken;
    static NSArray<NSString *> *s_sections;
    dispatch_once(&s_onceToken, ^{
        s_sections = @[ @"Vanilla player",
                        @"Akamai content protection player",
                        @"FairPlay content protection player" ];
    });
    
    return s_sections[section];
}

- (NSString *)titleForRow:(NSInteger)row
{
    static dispatch_once_t s_onceToken;
    static NSArray<NSString *> *s_rows;
    dispatch_once(&s_onceToken, ^{
        s_rows = @[ @"Unprotected Akamai HLS stream",
                    @"Akamai token-protected HLS stream",
                    @"FairPlay-protected HLS stream",
                    @"Non-Akamai HLS stream",
                    @"Non-Akamai MP3 stream",
                    @"Akamai MP3 stream" ];
    });
    
    return s_rows[row];
}

#pragma mark UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self titleForSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // UITableViewController on tvOS does not support static or dynamic table views defined in a storyboard,
    // apparently
    static NSString * const kCellIdentifier = @"MediaCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [self titleForRow:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static dispatch_once_t s_onceToken;
    static NSDictionary<NSNumber *, NSURL *> *s_URLs;
    dispatch_once(&s_onceToken, ^{
        s_URLs = @{ @0 : [NSURL URLWithString:@"https://rtsvodww-vh.akamaihd.net/i/genhi/2018/genhi_20180126_full_f_1067247-,301k,101k,701k,1201k,2001k,fra-ad,.mp4.csmil/master.m3u8"],
                    @1 : [NSURL URLWithString:@"https://srgssruni9ch-lh.akamaihd.net/i/enc9uni_ch@191320/master.m3u8"],
                    @2 : [NSURL URLWithString:@"https://rtsun-euwe.akamaized.net/9b2ba1d2-fefd-422f-8a8f-21b5da49a06d/rts1.ism/manifest(format=m3u8-aapl,encryption=cbcs-aapl,filter=nodvr)"],
                    @3 : [NSURL URLWithString:@"https://lsaplus.swisstxt.ch/audio/la-1ere_96.stream/playlist.m3u8"],
                    @4 : [NSURL URLWithString:@"http://stream.srg-ssr.ch/m/la-1ere/mp3_128"],
                    @5 : [NSURL URLWithString:@"https://srfaudio-a.akamaihd.net/delivery/world/75f44907-4638-422d-bc80-bbb14c9d9c93.mp3"] };
    });
    
    NSURL *URL = s_URLs[@(indexPath.row)];
    
    AVURLAsset *asset = nil;
    switch (indexPath.section) {
        case 0: {
            asset = [AVURLAsset assetWithURL:URL];
            break;
        }
            
        case 1: {
            asset = [AVURLAsset srg_akamaiTokenProtectedAssetWithURL:URL options:nil];
            break;
        }
            
        case 2: {
            NSURL *certificateURL = [NSURL URLWithString:@"https://srg.live.ott.irdeto.com/licenseServer/streaming/v1/SRG/getcertificate?applicationId=live"];
            asset = [AVURLAsset srg_fairPlayProtectedAssetWithURL:URL certificateURL:certificateURL options:nil];
            break;
        }
            
        default: {
            break;
        }
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    AVMutableMetadataItem *titleItem = [[AVMutableMetadataItem alloc] init];
    titleItem.identifier = AVMetadataCommonIdentifierTitle;
    titleItem.value = [self titleForRow:indexPath.row];
    titleItem.extendedLanguageTag = @"und";
    
    AVMutableMetadataItem *descriptionItem = [[AVMutableMetadataItem alloc] init];
    descriptionItem.identifier = AVMetadataCommonIdentifierDescription;
    descriptionItem.value = [NSString stringWithFormat:NSLocalizedString(@"Playing with %@", nil), [self titleForSection:indexPath.section]];
    descriptionItem.extendedLanguageTag = @"und";
    
    AVMutableMetadataItem *artworkItem = [[AVMutableMetadataItem alloc] init];
    artworkItem.identifier = AVMetadataCommonIdentifierArtwork;
    artworkItem.value = UIImagePNGRepresentation([UIImage imageNamed:@"artwork"]);
    artworkItem.extendedLanguageTag = @"und";
    
    playerItem.externalMetadata = @[ titleItem, descriptionItem, artworkItem ];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
    
    [self presentViewController:playerViewController animated:YES completion:^{
        [player play];
    }];
}

@end
