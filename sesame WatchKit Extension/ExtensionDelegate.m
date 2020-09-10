//
//  ExtensionDelegate.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "DoorManager.h"
#import "EnjoyLinkKeys.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    DoorManager *manager = [DoorManager sharedManager];
    NSLog(@"applicationDidFinishLaunching manager=%@", manager);
}

- (void)applicationDidBecomeActive {
    DoorManager *manager = [DoorManager sharedManager];
    NSLog(@"applicationDidBecomeActive manager=%@", manager);
    [manager startScan];
}

- (void)applicationWillResignActive {
    NSLog(@"applicationWillResignActive");
    
    DoorManager *manager = [DoorManager sharedManager];
    [manager stopScan];
}

- (void)applicationDidEnterBackground {
    DoorManager *manager = [DoorManager sharedManager];
    [manager applicationDidEnterBackground];
}

@end
