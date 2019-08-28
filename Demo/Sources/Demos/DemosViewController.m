//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "DemosViewController.h"

#import "Media.h"
#import "Resources.h"

#import <AVKit/AVKit.h>
#import <SRGContentProtection/SRGContentProtection.h>

@interface DemosViewController ()

@property (nonatomic) NSArray<Media *> *medias;

@end

@implementation DemosViewController

#pragma mark Object lifecycle

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ResourceNameForUIClass(self.class) bundle:nil];
    return [storyboard instantiateInitialViewController];
}

#pragma mark Getters and setters

- (NSString *)title
{
    return NSLocalizedString(@"Protections", nil);
}

#pragma mark Content

- (NSString *)titleForSection:(NSInteger)section
{
    static dispatch_once_t s_onceToken;
    static NSArray<NSString *> *s_sections;
    dispatch_once(&s_onceToken, ^{
        s_sections = @[ NSLocalizedString(@"Vanilla player", nil),
                        NSLocalizedString(@"Akamai content protection player", nil),
                        NSLocalizedString(@"FairPlay content protection player", nil) ];
    });
    
    return s_sections[section];
}

#pragma mark Media extraction

- (NSArray<Media *> *)medias
{
    if (! _medias) {
        NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MediaDemoConfiguration" ofType:@"plist"];
        _medias = [Media mediasFromFileAtPath:filePath];
    }
    return _medias;
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
    return self.medias.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    cell.textLabel.text = self.medias[indexPath.row].name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *URL = self.medias[indexPath.row].URL;
    
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
            NSURL *certificateURL = self.medias[indexPath.row].certificateURL;
            asset = [AVURLAsset srg_fairPlayProtectedAssetWithURL:URL certificateURL:certificateURL options:nil];
            break;
        }
            
        default: {
            break;
        }
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
#if TARGET_OS_TV
    AVMutableMetadataItem *titleItem = [[AVMutableMetadataItem alloc] init];
    titleItem.identifier = AVMetadataCommonIdentifierTitle;
    titleItem.value = self.medias[indexPath.row].name;
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
#endif
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
    
    [self presentViewController:playerViewController animated:YES completion:^{
        [player play];
    }];
}

@end
