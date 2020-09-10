//
//  EnjoyLinkKeys.h
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/11.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BleKey.h"

NS_ASSUME_NONNULL_BEGIN

@interface EnjoyLinkKeys : NSObject

+ (EnjoyLinkKeys *)sharedKeys;
- (BleKey *)findKey: (NSString *) macAddress;

@end

NS_ASSUME_NONNULL_END
