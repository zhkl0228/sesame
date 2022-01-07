//
//  MiDoor.h
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2022/1/7.
//  Copyright © 2022 廖正凯. All rights reserved.
//

#import "BleDoor.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiDoor : BleDoor

@property (retain, nonatomic) NSData *password;

+ (MiDoor *)door: (unsigned short)productId;

@end

NS_ASSUME_NONNULL_END
