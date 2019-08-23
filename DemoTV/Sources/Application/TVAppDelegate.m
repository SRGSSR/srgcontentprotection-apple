//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "TVAppDelegate.h"

#import "TVDemosViewController.h"

@interface TVAppDelegate ()

@end

@implementation TVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    
    TVDemosViewController *demosViewController = [[TVDemosViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:demosViewController];
    
    return YES;
}

@end
