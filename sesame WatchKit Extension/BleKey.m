//
//  BleKey.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/11.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "BleKey.h"

@implementation BleKey

@synthesize password;
@synthesize name;

-(id)init: (NSString *) password name: (NSString *) name {
    if((self = [super init])) {
        self.password = password;
        self.name = name;
    }
    return self;
}

-(NSString *)description {
    return name;
}

@end
