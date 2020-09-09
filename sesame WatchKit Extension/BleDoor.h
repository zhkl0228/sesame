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

@interface BleDoor : NSObject <CBPeripheralDelegate>

@property (retain, nonatomic) NSString *macAddress;

+ (BleDoor *)discoverByAdvertisementData: (NSDictionary<NSString *,id> *)advertisementData;

- (id) initWithMacAddress: (NSString *) _macAddress;

@end

NS_ASSUME_NONNULL_END
