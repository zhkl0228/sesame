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

@implementation LopeDoorV2

- (LopeDoorV2 *) initWithMacAddress: (NSString *) _macAddress {
    if((self = [super init])) {
        self.macAddress = _macAddress;
    }
    return self;
}

- (void)unlock: (CBPeripheral *)peripheral withCharacteristic: (CBCharacteristic *) characteristic {
//    NSDictionary *keys = [[NSDictionary alloc]initWithObjectsAndKeys:
//    @"uQ0uIglyUOaqXjv//F+now", @"B0:7E:11:F4:D9:D1",
//    @"i+pzrxp8LtsIKAJnphOupw", @"30:45:11:6B:9E:80",
//    @"nxzKBFmHUq+FJ9qm3kBE+A", @"40:BD:32:AF:A5:FD",
//    @"Il3ITyDWG4gL4axaXtN9VA", @"50:F1:4A:F8:79:3A",
//    @"C2NmSxiMnKxuXN9jvV1c0w", @"B0:7E:11:F4:F3:87",
//    @"N86d6EQUg2ZYCSx2YnISDw", @"40:BD:32:AF:AC:1D", nil];
    
    NSString *json = @"{\"encrypt\":true,\"code\":10000,\"desc\":\"请求执行成功！\",\"rts\":\"0000000000\",\"result\":{\"keys\":[{\"blueToothDeviceVo\":{\"deviceId\":15785,\"version\":\"32\",\"secretKey\":\"uQ0uIglyUOaqXjv//F+now\",\"macAddress\":\"B0:7E:11:F4:D9:D1\",\"guardId\":12148,\"guardName\":\"9栋负一正门\",\"code\":\"20190524173555\",\"supplierType\":\"1\",\"orderNum\":0},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":10860,\"version\":\"32\",\"secretKey\":\"i+pzrxp8LtsIKAJnphOupw\",\"macAddress\":\"30:45:11:6B:9E:80\",\"guardId\":8471,\"guardName\":\"9栋大堂\",\"code\":\"20181127160712\",\"supplierType\":\"1\",\"orderNum\":1},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8156,\"version\":\"32\",\"secretKey\":\"nxzKBFmHUq+FJ9qm3kBE+A\",\"macAddress\":\"40:BD:32:AF:A5:FD\",\"guardId\":6765,\"guardName\":\"北门\",\"code\":\"20181017164904\",\"supplierType\":\"1\",\"orderNum\":3},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8157,\"version\":\"32\",\"secretKey\":\"Il3ITyDWG4gL4axaXtN9VA\",\"macAddress\":\"50:F1:4A:F8:79:3A\",\"guardId\":6764,\"guardName\":\"西门\",\"code\":\"20181017172830\",\"supplierType\":\"1\",\"orderNum\":4},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":15786,\"version\":\"32\",\"secretKey\":\"C2NmSxiMnKxuXN9jvV1c0w\",\"macAddress\":\"B0:7E:11:F4:F3:87\",\"guardId\":12149,\"guardName\":\"9栋负二正门\",\"code\":\"20190524174920\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"},{\"blueToothDeviceVo\":{\"deviceId\":8158,\"version\":\"32\",\"secretKey\":\"N86d6EQUg2ZYCSx2YnISDw\",\"macAddress\":\"40:BD:32:AF:AC:1D\",\"guardId\":6763,\"guardName\":\"东门单车行道\",\"code\":\"20181017180546\",\"supplierType\":\"1\",\"orderNum\":5},\"keyType\":\"01\"}],\"url\":\"semtec-ss1\"}}";
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *result = [response objectForKey:@"result"];
    NSDictionary *guard = nil;
    for(NSDictionary *key in [result objectForKey:@"keys"]) {
        NSDictionary *vo = [key objectForKey:@"blueToothDeviceVo"];
        NSString *macAddress = [vo objectForKey:@"macAddress"];
        if([self.macAddress isEqualToString:macAddress]) {
            guard = vo;
            break;
        }
    }
    
    if(guard) {
        InterfaceController *controller = [InterfaceController sharedController];
        [controller setGuardName:[guard objectForKey:@"guardName"]];
        
        NSString *secretKey = [guard objectForKey:@"secretKey"];
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
        NSLog(@"unlock_door peripheral=%@, characteristic=%@, guard=%@, pwd=%@, block=%@", peripheral, characteristic, guard, pwd, block);
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
