//
//  ExtensionDelegate.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "BleDoor.h"

@implementation ExtensionDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState central=%@", central);
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral peripheral=%@", peripheral);
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    unsigned short manufacturerId = 0;
    NSString *name = [peripheral name];
    NSData *manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    if(manufacturerData) {
        [manufacturerData getBytes:&manufacturerId length:sizeof(manufacturerId)];
    }
    NSLog(@"didDiscoverPeripheral central=%@, peripheral=%@, manufacturerData=%@, RSSI=%@, manufacturerId=0x%x, name=%@", central, peripheral, manufacturerData, RSSI, manufacturerId, name);
    
    if(manufacturerId == 0x4f4c) {
        unsigned char dev_type = 0;
        unsigned char fw_type = 0;
        int dev_id = 0;
        char mac[6];
        [manufacturerData getBytes:&dev_type range:NSMakeRange(2, 1)];
        [manufacturerData getBytes:&fw_type range:NSMakeRange(3, 1)];
        [manufacturerData getBytes:&dev_id range:NSMakeRange(4, 4)];
        [manufacturerData getBytes:mac range:NSMakeRange(8, sizeof(mac))];
        
        dev_id = ntohl(dev_id);
        char buf[18];
        int pos = 0;
        for(int i = 0; i < 6; i++) {
            pos += sprintf(&buf[pos], "%02X", mac[i] & 0xff);
        }
        
        NSString *mac_address = [NSString stringWithFormat:@"%s", buf];
        BleDoor *door = [BleDoor new];
        [door setMac_address:mac_address];
        [peripheral setDelegate:door];
        NSLog(@"connectPeripheral dev_type=%u, fw_type=%u, dev_id=%d, mac=%@", dev_type, fw_type, dev_id, mac_address);
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)applicationDidFinishLaunching {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSLog(@"applicationDidFinishLaunching centralManager=%@", self.centralManager);
}

- (void)applicationDidBecomeActive {
    CBManagerState state = [self.centralManager state];
    NSLog(@"applicationDidBecomeActive state=%d", state);
    
    if(state == CBManagerStatePoweredOn && ![self.centralManager isScanning]) {
         [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)applicationWillResignActive {
    NSLog(@"applicationWillResignActive");
    
    if([self.centralManager isScanning]) {
        [self.centralManager stopScan];
    }
}

- (void)applicationDidEnterBackground {
    NSLog(@"applicationDidEnterBackground");
}

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    for (WKRefreshBackgroundTask * task in backgroundTasks) {
        NSLog(@"handleBackgroundTasks task=%@", task);
        // Check the Class of each task to decide how to process it
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            // Snapshot tasks have a unique completion call, make sure to set your expiration date
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
        } else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKWatchConnectivityRefreshBackgroundTask *backgroundTask = (WKWatchConnectivityRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKRelevantShortcutRefreshBackgroundTask class]]) {
            // Be sure to complete the relevant-shortcut task once you’re done.
            WKRelevantShortcutRefreshBackgroundTask *relevantShortcutTask = (WKRelevantShortcutRefreshBackgroundTask*)task;
            [relevantShortcutTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKIntentDidRunRefreshBackgroundTask class]]) {
            // Be sure to complete the intent-did-run task once you’re done.
            WKIntentDidRunRefreshBackgroundTask *intentDidRunTask = (WKIntentDidRunRefreshBackgroundTask*)task;
            [intentDidRunTask setTaskCompletedWithSnapshot:NO];
        } else {
            // make sure to complete unhandled task types
            [task setTaskCompletedWithSnapshot:NO];
        }
    }
}

@end
