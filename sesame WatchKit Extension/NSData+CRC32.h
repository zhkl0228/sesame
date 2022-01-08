//
//  NSData+CRC32.h
//  sesame WatchKit Extension
//
//  Created by LiaoZhengKai on 2022/1/8.
//  Copyright © 2022 廖正凯. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef NSData_CRC32_h
#define NSData_CRC32_h

@interface NSData (CRC32)

-(int32_t) crc32;

@end

#endif /* NSData_CRC32_h */
