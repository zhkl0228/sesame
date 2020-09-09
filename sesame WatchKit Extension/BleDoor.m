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

static NSData *decode_hex(NSString *hexString) {
    const char *chars = [hexString UTF8String];
    int i = 0;
    NSUInteger len = hexString.length;

    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;

    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

static void unlock_door(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSString *mac) {
    NSDictionary *keys = [[NSDictionary alloc]initWithObjectsAndKeys:
    @"b90d2e22097250e6aa5e3bfffc5fa7a3", @"B0:7E:11:F4:D9:D1",
    @"8bea73af1a7c2edb08280267a613aea7", @"30:45:11:6B:9E:80",
    @"9f1cca04598752af8527daa6de4044f8", @"40:BD:32:AF:A5:FD",
    @"225dc84f20d61b880be1ac5a5ed37d54", @"50:F1:4A:F8:79:3A",
    @"0b63664b188c9cac6e5cdf63bd5d5cd3", @"B0:7E:11:F4:F3:87",
    @"37ce9de84414836658092c766272120f", @"40:BD:32:AF:AC:1D", nil];
    
    NSString *secretKey = [keys objectForKey:mac];
    if(secretKey) {
        NSData *pwd = decode_hex(secretKey);
        
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
    } else {
        NSLog(@"unlock_door peripheral=%@, characteristic=%@, secretKey=%@, mac=%@", peripheral, characteristic, secretKey, mac);
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
            unlock_door(peripheral, characteristic, mac_address);
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
