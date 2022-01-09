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
#import "MiDoor.h"

@implementation DoorManager

+ (DoorManager *)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if(self = [super init]) {
        self.discoveredPeripheral = nil;
        self.connectingDoors = [NSMutableDictionary dictionaryWithCapacity:5];
        self.discoveredDoors = [NSMutableDictionary dictionaryWithCapacity:50];
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

- (void)cancelPeripheralConnection {
    NSLog(@"cancelPeripheralConnection discoveredPeripheral=%@", self.discoveredPeripheral);
    
    if(self.discoveredPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        self.discoveredPeripheral = nil;
    }
    [self stopScan];
}

- (void)startScan {
    CBManagerState state = [self.centralManager state];
    BOOL isScanning = [self.centralManager isScanning];
    if(state == CBManagerStatePoweredOn && !isScanning) {
        NSLog(@"startScan discoveredPeripheral=%@", self.discoveredPeripheral);
        InterfaceController *controller = [InterfaceController sharedController];
        [controller setGuardName:nil];
        CBUUID *lopeDoorV2 = [CBUUID UUIDWithString:@"00002560-0000-1000-8000-00805f9b34fb"];
        CBUUID *miService = [MiDoor MI_SERVICE_UUID];
        CBUUID *miLockService = [CBUUID UUIDWithString: @"00001000-0065-6c62-2e74-6f696d2e696d"];
        [self.centralManager scanForPeripheralsWithServices: [NSArray arrayWithObjects: lopeDoorV2, miService, miLockService, nil] options:nil];
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
    
    [self.connectingDoors removeObjectForKey:[[peripheral identifier] UUIDString]];
    if(self.discoveredPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
        self.discoveredPeripheral = nil;
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral central=%@, peripheral=%@, error=%@", central, peripheral, error);
    
    [self.connectingDoors removeObjectForKey:[[peripheral identifier] UUIDString]];
    if(self.discoveredPeripheral == peripheral) {
        self.discoveredPeripheral = nil;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"didConnectPeripheral peripheral=%@", peripheral);
    BleDoor *door = [self.connectingDoors valueForKey:[[peripheral identifier] UUIDString]];
    if(door) {
        [door tryUnlock: peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    BleDoor *door = [self.discoveredDoors valueForKey: [[peripheral identifier] UUIDString]];
    if(door) {
        NSLog(@"didDiscoverPeripheral peripheral=%@, door=%@", peripheral, door);
        [self tryConnectPeripheral:peripheral door: door];
        return;
    }
    
    door = [BleDoor discoverByAdvertisementData:advertisementData];
    if(door) {
        NSLog(@"didDiscoverPeripheral central=%@, peripheral=%@, advertisementData=%@, RSSI=%@, door=%@", central, peripheral, advertisementData, RSSI, door);
        [self.discoveredDoors setValue: door forKey: [[peripheral identifier] UUIDString]];
        [self tryConnectPeripheral:peripheral door: door];
    }
}

- (void) tryConnectPeripheral: (CBPeripheral *) peripheral door: (BleDoor *) door {
    if(self.discoveredPeripheral && self.discoveredPeripheral != peripheral) {
        return;
    }

    self.discoveredPeripheral = peripheral;
    
    if([peripheral state] == CBPeripheralStateConnected
) {
        [door tryUnlock: peripheral];
        return;
    }
    
    [self.connectingDoors setValue:door forKey:[[peripheral identifier] UUIDString]];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

@end
