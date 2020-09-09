//
//  BleDoor.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "BleDoor.h"
#import "NSData+FastHex.h"
#import "MF_Base64Additions.h"

@implementation BleDoor

+ (BleDoor *)discoverByAdvertisementData: (NSDictionary<NSString *,id> *)advertisementData {
    NSData *manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    if(manufacturerData && [manufacturerData length] > 2) {
        unsigned short manufacturerId = 0;
        [manufacturerData getBytes:&manufacturerId length:2];
        if(manufacturerId == 0x4f4c) { // lopesdk BleDoorV2
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
            return [[BleDoor alloc] initWithMacAddress: macAddress];
        }
    }
    return nil;
}

- (BleDoor *) initWithMacAddress: (NSString *) _macAddress {
    if((self = [super init])) {
        self.macAddress = _macAddress;
    }
    return self;
}

- (void) unlock: (CBPeripheral *)peripheral withCharacteristic: (CBCharacteristic *) characteristic {
    NSDictionary *keys = [[NSDictionary alloc]initWithObjectsAndKeys:
    @"uQ0uIglyUOaqXjv//F+now", @"B0:7E:11:F4:D9:D1",
    @"i+pzrxp8LtsIKAJnphOupw", @"30:45:11:6B:9E:80",
    @"nxzKBFmHUq+FJ9qm3kBE+A", @"40:BD:32:AF:A5:FD",
    @"Il3ITyDWG4gL4axaXtN9VA", @"50:F1:4A:F8:79:3A",
    @"C2NmSxiMnKxuXN9jvV1c0w", @"B0:7E:11:F4:F3:87",
    @"N86d6EQUg2ZYCSx2YnISDw", @"40:BD:32:AF:AC:1D", nil];
    
    NSString *secretKey = [keys objectForKey:self.macAddress];
    if(secretKey) {
        NSData *pwd = [NSData dataWithBase64String:secretKey];
        
        int8_t command = -127;
        int8_t data[20];
        memset(data, 0, 20);
        data[0] = 0x55;
        data[1] = command;
        data[2] = 16;
        [pwd getBytes:&data[3] length:16];
        int8_t checksum = command;
        for(int i = 2; i < 20; i++) {
            checksum ^= data[i];
        }
        data[19] = checksum;
        
        NSData *block = [NSData dataWithBytes:data length:20];
        NSLog(@"unlock_door peripheral=%@, characteristic=%@, secretKey=%@, pwd=%@, block=%@", peripheral, characteristic, secretKey, pwd, block);
        [peripheral writeValue:block forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeSuccess];
    } else {
        NSLog(@"unlock peripheral=%@, characteristic=%@, secretKey=%@, macAddress=%@", peripheral, characteristic, secretKey, self.macAddress);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    NSLog(@"didDiscoverCharacteristicsForService peripheral=%@, service=%@, error=%@", peripheral, service, error);
    
    if([peripheral state] != CBPeripheralStateConnected) {
        return;
    }
    NSArray<CBCharacteristic *> *characteristics = [service characteristics];
    for(CBCharacteristic *characteristic in characteristics) {
        CBUUID *u = [characteristic UUID];
        if([u isEqual:[CBUUID UUIDWithString:@"00002561-0000-1000-8000-00805f9b34fb"]]) {
            NSLog(@"didDiscoverServices found char1 ble door");
            [self unlock:peripheral withCharacteristic:characteristic];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices peripheral=%@, error=%@", peripheral, error);
    
    if([peripheral state] != CBPeripheralStateConnected) {
        return;
    }
    NSArray<CBService *> *services = [peripheral services];
    for(CBService *service in services) {
        CBUUID *uuid = [service UUID];
        if([uuid isEqual:[CBUUID UUIDWithString:@"00002560-0000-1000-8000-00805f9b34fb"]]) {
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

@end
