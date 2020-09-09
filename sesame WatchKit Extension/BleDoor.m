//
//  BleDoor.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "BleDoor.h"
#import "NSData+FastHex.h"
#import "LopeDoorV2.h"

@implementation BleDoor

- (void)unlock: (CBPeripheral *)peripheral withCharacteristic: (CBCharacteristic *) characteristic {
    [self doesNotRecognizeSelector:_cmd];
}

+ (BleDoor *)discoverByAdvertisementData: (NSDictionary<NSString *,id> *)advertisementData {
    NSData *manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    if(manufacturerData && [manufacturerData length] > 2) {
        unsigned short manufacturerId = 0;
        [manufacturerData getBytes:&manufacturerId length:2];
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
            return [[LopeDoorV2 alloc] initWithMacAddress: macAddress];
        }
    }
    return nil;
}

@end
