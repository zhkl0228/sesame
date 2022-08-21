//
//  BleDoor.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "BleDoor.h"
#import "LopeDoorV2.h"
#import "MiDoor.h"

@implementation BleDoor

- (void)unlock: (CBPeripheral *)peripheral withCharacteristic: (CBCharacteristic *) characteristic {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSArray<CBUUID *> *)serviceUUIDs {
    return nil;
}

- (NSArray<CBUUID *> *) characteristicUUIDs:(CBService *)service {
    return nil;
}

- (void)tryUnlock: (CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    [peripheral discoverServices: [self serviceUUIDs]];
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
    if(serviceData) {
        NSData *data = [serviceData objectForKey: [MiDoor MI_SERVICE_UUID]];
        if(data) {
            struct mi_service_data {
                uint16_t frame_control;
                uint16_t product_id;
                uint8_t frame_counter;
            };
            struct mi_service_data mi_data;
            [data getBytes:&mi_data length:sizeof(struct mi_service_data)];
            NSLog(@"discoverByAdvertisementData serviceData=%@, data=%@, product_id=0x%x", serviceData, data, mi_data.product_id);
            MiDoor *door = [MiDoor door: mi_data.product_id];
            if(door) {
                return door;
            }
        }
    }
    return nil;
}

@end
