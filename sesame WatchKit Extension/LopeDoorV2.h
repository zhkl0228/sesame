//
//  LopeDoorV2.h
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/9.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BleDoor.h"

NS_ASSUME_NONNULL_BEGIN

@interface LopeDoorV2 : BleDoor

@property (retain, nonatomic) NSString *macAddress;

- (id) initWithMacAddress: (NSString *) _macAddress;

@end

NS_ASSUME_NONNULL_END
