//
//  BleKey.h
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/11.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BleKey : NSObject

-(id)init: (NSString *) password name: (NSString *) name;

@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *name;

@end

NS_ASSUME_NONNULL_END
