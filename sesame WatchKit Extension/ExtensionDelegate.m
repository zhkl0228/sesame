//
//  ExtensionDelegate.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "ExtensionDelegate.h"
#import "BleDoor.h"

static NSMutableDictionary<NSString*, BleDoor*> *doorDict;
static CBPeripheral *discoveredPeripheral;

@implementation ExtensionDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState central=%@", central);
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral central=%@, peripheral=%@, error=%@", central, peripheral, error);
    
    [doorDict removeObjectForKey:[[peripheral identifier]UUIDString]];
    if(discoveredPeripheral) {
        [self.centralManager cancelPeripheralConnection:discoveredPeripheral];
        discoveredPeripheral = nil;
    }
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral central=%@, peripheral=%@, error=%@", central, peripheral, error);
    
    [doorDict removeObjectForKey:[[peripheral identifier]UUIDString]];
    if(discoveredPeripheral == peripheral) {
        discoveredPeripheral = nil;
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral peripheral=%@", peripheral);
    BleDoor *door = [doorDict valueForKey:[[peripheral identifier]UUIDString]];
    if(door) {
        [peripheral setDelegate:door];
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    unsigned short manufacturerId = 0;
    NSData *manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    if(manufacturerData && [manufacturerData length] >= sizeof(manufacturerId)) {
        [manufacturerData getBytes:&manufacturerId length:sizeof(manufacturerId)];
    }
    NSLog(@"didDiscoverPeripheral central=%@, peripheral=%@, manufacturerData=%@, RSSI=%@, manufacturerId=0x%x", central, peripheral, manufacturerData, RSSI, manufacturerId);
    
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
        char buf[20];
        int pos = 0;
        for(int i = 0; i < 6; i++) {
            pos += sprintf(&buf[pos], "%02X:", mac[i] & 0xff);
        }
        buf[pos-1] = 0;
        
        NSString *macAddress = [NSString stringWithFormat:@"%s", buf];
        BleDoor *door = [BleDoor new];
        [door setMacAddress:macAddress];
        NSLog(@"connectPeripheral dev_type=%u, fw_type=%u, dev_id=%d, macAddress=%@", dev_type, fw_type, dev_id, macAddress);
        [self tryConnectPeripheral:peripheral door: door];
    }
}

- (void) tryConnectPeripheral: (CBPeripheral *) peripheral door: (BleDoor *) door {
    if(discoveredPeripheral != nil && discoveredPeripheral != peripheral) {
        return;
    }

    discoveredPeripheral = peripheral;
    [doorDict setValue:door forKey:[[peripheral identifier]UUIDString]];
    [self.centralManager connectPeripheral:peripheral options:[NSDictionary dictionary]];
}

- (void)applicationDidFinishLaunching {
    doorDict = [NSMutableDictionary dictionaryWithCapacity:100];
    discoveredPeripheral = nil;
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
    
//    if([self.centralManager isScanning]) {
//        [self.centralManager stopScan];
//    }
}

- (void)applicationDidEnterBackground {
    NSLog(@"applicationDidEnterBackground discoveredPeripheral=%@", discoveredPeripheral);
    
//    if(discoveredPeripheral) {
//        [self.centralManager cancelPeripheralConnection:discoveredPeripheral];
//        discoveredPeripheral = nil;
//    }
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
