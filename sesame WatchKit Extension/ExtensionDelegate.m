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

- (void)applicationWillEnterForeground {
    WKExtension *extension = [WKExtension sharedExtension];
    BOOL isApplicationRunningInDock = [extension isApplicationRunningInDock];
    NSLog(@"applicationWillEnterForeground isApplicationRunningInDock=%d", isApplicationRunningInDock);
    
    DoorManager *manager = [DoorManager sharedManager];
    [manager startScan];
}

- (void)applicationDidEnterBackground {
    DoorManager *manager = [DoorManager sharedManager];
    [manager cancelPeripheralConnection];
//    NSDate *preferredDate = [NSDate dateWithTimeIntervalSinceNow: 10];
//    NSLog(@"applicationDidEnterBackground preferredDate=%@", preferredDate);
//    WKExtension *extension = [WKExtension sharedExtension];
//    [extension scheduleBackgroundRefreshWithPreferredDate:preferredDate userInfo:nil scheduledCompletion:^(NSError * _Nullable error) {
//        NSLog(@"scheduleBackgroundRefreshWithPreferredDate error=%@", error);
//    }];
}

//- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
//    NSLog(@"handleBackgroundTasks backgroundTasks=%@", backgroundTasks);
//
//    for (WKRefreshBackgroundTask * task in backgroundTasks) {
//        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
//            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
//            backgroundTask.expirationHandler = ^{
//                NSLog(@"expirationHandler");
//                DoorManager *manager = [DoorManager sharedManager];
//                [manager cancelPeripheralConnection];
//            };
//        } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
//            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
//            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
//        } else {
//            [task setTaskCompletedWithSnapshot: NO];
//        }
//    }
//}

@end
