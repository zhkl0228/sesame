//
//  BleDoor.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "BleDoor.h"

@implementation BleDoor

@synthesize mac_address;

static void unlock_door(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSString *mac) {
    NSDictionary *keys = [[NSDictionary alloc]initWithObjectsAndKeys:
    @"uQ0uIglyUOaqXjv//F+now", @"B0:7E:11:F4:D9:D1",
    @"i+pzrxp8LtsIKAJnphOupw", @"30:45:11:6B:9E:80",
    @"nxzKBFmHUq+FJ9qm3kBE+A", @"40:BD:32:AF:A5:FD",
    @"Il3ITyDWG4gL4axaXtN9VA", @"50:F1:4A:F8:79:3A",
    @"C2NmSxiMnKxuXN9jvV1c0w", @"B0:7E:11:F4:F3:87",
    @"N86d6EQUg2ZYCSx2YnISDw", @"40:BD:32:AF:AC:1D" ,nil];
    
    NSString *secretKey = [keys objectForKey:mac];
    if(secretKey) {
        NSData *pwd = [[NSData alloc] initWithBase64EncodedString:secretKey options:0];
        NSLog(@"unlock_door peripheral=%@, characteristic=%@, secretKey=%@, pwd=%@", peripheral, characteristic, secretKey, pwd);
        
        char command = -127;
        char data[20];
        data[0] = 0x55;
        data[1] = command;
        data[2] = 16;
        [pwd getBytes:&data[3] length:16];
        char checksum = command;
        for(int i = 2; i < 20; i++) {
            checksum ^= data[i];
        }
        data[19] = checksum;
        [peripheral writeValue:[NSData dataWithBytes:data length:20] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    } else {
        NSLog(@"unlock_door peripheral=%@, characteristic=%@, secretKey=%@, mac=%@", peripheral, characteristic, secretKey, mac);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    NSArray<CBService *> *services = [peripheral services];
    NSLog(@"didDiscoverServices peripheral=%@, error=%@, services=%@", peripheral, error, services);
    
    if(error == nil) {
        for(CBService *service in services) {
            CBUUID *uuid = [service UUID];
            if([[uuid UUIDString] isEqualToString:@"00002560-0000-1000-8000-00805f9b34fb"]) {
                NSArray<CBCharacteristic *> *characteristics = [service characteristics];
                for(CBCharacteristic *characteristic in characteristics) {
                    CBUUID *u = [characteristic UUID];
                    if([[u UUIDString] isEqualToString:@"00002561-0000-1000-8000-00805f9b34fb"]) {
                        NSLog(@"didDiscoverServices found char1 ble door");
                        unlock_door(peripheral, characteristic, mac_address);
                    }
                }
            }
        }
    }
}

@end
