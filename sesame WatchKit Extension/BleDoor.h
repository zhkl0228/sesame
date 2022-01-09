//
//  BleDoor.h
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

struct mi_service_data {
    uint16_t frame_control;
    uint16_t product_id;
    uint8_t frame_counter;
};

@interface BleDoor : NSObject <CBPeripheralDelegate>

+ (BleDoor *)discoverByAdvertisementData: (NSDictionary<NSString *,id> *)advertisementData;

- (void)unlock: (CBPeripheral *)peripheral withCharacteristic: (CBCharacteristic *) characteristic;

- (void)tryUnlock: (CBPeripheral *)peripheral;

- (NSArray<CBUUID *> *)serviceUUIDs;
- (NSArray<CBUUID *> *)characteristicUUIDs:(CBService *)service;

@end

NS_ASSUME_NONNULL_END
