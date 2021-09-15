//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AppDelegate.h"

#import "DemosViewController.h"

@import AVFoundation;

@implementation AppDelegate

#pragma mark UIApplicationDelegate protocol

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:NULL];
    
    if (@available(iOS 13, tvOS 13, *)) {}
    else {
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [self.window makeKeyAndVisible];
        
        DemosViewController *demosViewController = [[DemosViewController alloc] init];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:demosViewController];
    }
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0))
{
    return [[UISceneConfiguration alloc] initWithName:@"Default" sessionRole:connectingSceneSession.role];
}

@end
