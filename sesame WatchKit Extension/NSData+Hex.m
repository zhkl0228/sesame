//
//  NSData+Hex.m
//  sesame WatchKit Extension
//
//  Created by LiaoZhengKai on 2022/1/8.
//  Copyright © 2022 廖正凯. All rights reserved.
//

#import "NSData+Hex.h"

@implementation NSData (Hex)

-(NSString *) toHexString {
  NSUInteger capacity = self.length * 2;
  NSMutableString *buffer = [NSMutableString stringWithCapacity:capacity];
  const char *buf = (const char*) self.bytes;
  NSUInteger i;
  for (i=0; i<self.length; i++) {
    [buffer appendFormat:@"%02x", (buf[i] & 0xff)];
  }
  return buffer;
}

@end
