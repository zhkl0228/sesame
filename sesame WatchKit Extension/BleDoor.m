//
//  BleDoor.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "BleDoor.h"
#import "LopeDoorV2.h"

@implementation BleDoor

- (void)unlock: (CBPeripheral *)peripheral withCharacteristic: (CBCharacteristic *) characteristic {
    [self doesNotRecognizeSelector:_cmd];
}

+ (BleDoor *)discoverByAdvertisementData: (NSDictionary<NSString *,id> *)advertisementData {
    NSData *manufacturerData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
    if(manufacturerData && [manufacturerData length] >= 2) {
        unsigned short manufacturerId = 0;
        [manufacturerData getBytes:&manufacturerId length:2];
        NSData *remaining = [manufacturerData subdataWithRange:NSMakeRange(2, [manufacturerData length]-2)];
        BleDoor *door = [LopeDoorV2 door:manufacturerId manufacturerData:remaining];
        if(door) {
            return door;
        }
    }
    NSDictionary *serviceData = [advertisementData valueForKey: CBAdvertisementDataServiceDataKey];
    NSLog(@"discoverByAdvertisementData serviceData=%@", serviceData);
    return nil;
}

@end
