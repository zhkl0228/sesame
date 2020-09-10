//
//  DoorManager.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/9.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "DoorManager.h"
#import "InterfaceController.h"

@implementation DoorManager

+ (DoorManager *)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (id)init {
    if(self = [super init]) {
        self.discoveredPeripheral = nil;
        self.doorDict = [NSMutableDictionary dictionaryWithCapacity:5];
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState central=%@", central);
    
    CBManagerState state = [self.centralManager state];
    WKExtension *extension = [WKExtension sharedExtension];
    if(state == CBManagerStatePoweredOn && ![self.centralManager isScanning] && [extension applicationState] == WKApplicationStateActive) {
        [self startScan];
    }
}

- (void)applicationDidEnterBackground {
    NSLog(@"applicationDidEnterBackground discoveredPeripheral=%@, isApplicationRunningInDock=%d", self.discoveredPeripheral, [[WKExtension sharedExtension] isApplicationRunningInDock]);
    
    if(self.discoveredPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        self.discoveredPeripheral = nil;
    }
}

- (void)startScan {
    CBManagerState state = [self.centralManager state];
    if(state == CBManagerStatePoweredOn && ![self.centralManager isScanning]) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        InterfaceController *controller = [InterfaceController sharedController];
        [controller setGuardName:nil];
    }
}

- (void)stopScan {
    NSLog(@"stopScan discoveredPeripheral=%@", self.discoveredPeripheral);
    if([self.centralManager isScanning]) {
        [self.centralManager stopScan];
    }
    if(self.discoveredPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        self.discoveredPeripheral = nil;
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral central=%@, peripheral=%@, error=%@", central, peripheral, error);
    
    [self.doorDict removeObjectForKey:[[peripheral identifier]UUIDString]];
    if(self.discoveredPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        self.discoveredPeripheral = nil;
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral central=%@, peripheral=%@, error=%@", central, peripheral, error);
    
    [self.doorDict removeObjectForKey:[[peripheral identifier]UUIDString]];
    if(self.discoveredPeripheral == peripheral) {
        self.discoveredPeripheral = nil;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral peripheral=%@", peripheral);
    BleDoor *door = [self.doorDict valueForKey:[[peripheral identifier]UUIDString]];
    if(door) {
        [peripheral setDelegate:door];
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    NSLog(@"didDiscoverPeripheral central=%@, peripheral=%@, advertisementData=%@, RSSI=%@", central, peripheral, advertisementData, RSSI);
    
    BleDoor *door = [BleDoor discoverByAdvertisementData:advertisementData];
    if(door) {
        [self tryConnectPeripheral:peripheral door: door];
    }
}

- (void) tryConnectPeripheral: (CBPeripheral *) peripheral door: (BleDoor *) door {
    if(self.discoveredPeripheral && self.discoveredPeripheral != peripheral) {
        return;
    }

    self.discoveredPeripheral = peripheral;
    [self.doorDict setValue:door forKey:[[peripheral identifier]UUIDString]];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

@end
