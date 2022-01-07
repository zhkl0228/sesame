//
//  MiDoor.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2022/1/7.
//  Copyright © 2022 廖正凯. All rights reserved.
//

#import "MiDoor.h"

@implementation MiDoor

+ (NSData *) hexStringToData:(NSString *) hexString {
    const char *chars = [hexString UTF8String];
    int i = 0;
    int len = (int)hexString.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len/2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;

    while (i<len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

+ (MiDoor *)door: (unsigned short)productId {
    if(productId == 0x8cf) {
        return [[MiDoor alloc] initWithPassword: [MiDoor hexStringToData: @"6c995fc25f0444dbb21d603be65dc2f59d4b53327b2e299d03cecca43fe73614"]];
    }
    return nil;
}

- (MiDoor *) initWithPassword: (NSData *) _password {
    if((self = [super init])) {
        self.password = _password;
    }
    return self;
}

@end
