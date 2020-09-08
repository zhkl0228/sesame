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

@property (strong, nonatomic) NSString *mac_address;

@end

NS_ASSUME_NONNULL_END
