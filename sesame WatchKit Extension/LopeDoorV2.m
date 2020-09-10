//
//  LopeDoorV2.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/9.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "MF_Base64Additions.h"
#import "LopeDoorV2.h"
#import "InterfaceController.h"
#import "BleKey.h"
#import "EnjoyLinkKeys.h"

@implementation LopeDoorV2

+ (LopeDoorV2 *)door: (unsigned short)manufacturerId manufacturerData: (NSData *)manufacturerData {
    if(manufacturerId == 0x4f4c) {
        unsigned char dev_type = 0;
        unsigned char fw_type = 0;
        int dev_id = 0;
        char mac[6];
        [manufacturerData getBytes:&dev_type range:NSMakeRange(0, 1)];
        [manufacturerData getBytes:&fw_type range:NSMakeRange(1, 1)];
        [manufacturerData getBytes:&dev_id range:NSMakeRange(2, 4)];
        [manufacturerData getBytes:mac range:NSMakeRange(6, sizeof(mac))];
        
        dev_id = ntohl(dev_id);
        char buf[20];
        int pos = 0;
        for(int i = 0; i < 6; i++) {
            pos += sprintf(&buf[pos], "%02X:", mac[i] & 0xff);
        }
        buf[pos-1] = 0;
        
        NSString *macAddress = [NSString stringWithFormat:@"%s", buf];
        return [[LopeDoorV2 alloc] initWithMacAddress: macAddress];
    }
    return nil;
}

- (LopeDoorV2 *) initWithMacAddress: (NSString *) _macAddress {
    if((self = [super init])) {
        self.macAddress = _macAddress;
    }
    return self;
}

- (void)unlock: (CBPeripheral *)peripheral withCharacteristic: (CBCharacteristic *) characteristic {
    BleKey *key = [[EnjoyLinkKeys sharedKeys] findKey:self.macAddress];
    if(key) {
        InterfaceController *controller = [InterfaceController sharedController];
        [controller setGuardName:[key name]];
        
        NSString *secretKey = [key password];
        NSData *pwd = [NSData dataWithBase64String:secretKey]; // length is 16
        
        int8_t command = -127;
        int8_t data[20];
        memset(data, 0, 20);
        data[0] = 0x55;
        data[1] = command;
        data[2] = (int8_t) [pwd length];
        [pwd getBytes:&data[3] length:[pwd length]];
        int8_t checksum = command;
        for(int i = 2; i < 20; i++) {
            checksum ^= data[i];
        }
        data[19] = checksum;
        
        NSData *block = [NSData dataWithBytes:data length:20];
        NSLog(@"unlock_door peripheral=%@, characteristic=%@, pwd=%@, block=%@", peripheral, characteristic, pwd, block);
        [peripheral writeValue:block forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeSuccess];
    } else {
        NSLog(@"unlock peripheral=%@, characteristic=%@, macAddress=%@", peripheral, characteristic, self.macAddress);
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

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
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
