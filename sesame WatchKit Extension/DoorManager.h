//
//  DoorManager.h
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/9.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleDoor.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoorManager : NSObject <CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableDictionary<NSString*, BleDoor*> *doorDict;
@property (strong, nonatomic, nullable) CBPeripheral *discoveredPeripheral;

+ (DoorManager *)sharedManager;
- (void)applicationDidEnterBackground;
- (void)startScan;
- (void)stopScan;

@end

NS_ASSUME_NONNULL_END
