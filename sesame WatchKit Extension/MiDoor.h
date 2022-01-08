//
//  MiDoor.h
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2022/1/7.
//  Copyright © 2022 廖正凯. All rights reserved.
//

#import "BleDoor.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum _AuthState {
    Start = 0,
    WaitSendPublicKey,
    SentPublicKey,
    WaitReceivePublicKey,
    ReceivePublicKey,
    WaitSendAuth,
    SentAuth,
    WaitAuthStatus
    
} AuthState;

@interface MiDoor : BleDoor

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSData *password;

@property (retain, nonatomic, nullable) CBCharacteristic *readCharacteristic;
@property (retain, nonatomic, nullable) CBCharacteristic *authenticationCharacteristic;
@property (retain, nonatomic, nullable) CBCharacteristic *securityAuthCharacteristic;
@property (retain, nonatomic, nullable) CBCharacteristic *unlockCharacteristic;
@property (retain, nonatomic, nullable) CBCharacteristic *notifyCharacteristic;
@property (retain, nonatomic, nullable) NSData *publicKey;
@property (retain, nonatomic, nullable) NSData *privateKey;
@property (retain, nonatomic, nullable) NSMutableData *peerPublicKey;
@property (assign) AuthState authState;

+ (MiDoor *)door: (unsigned short)productId;

+ (CBUUID *) MI_SERVICE_UUID;

@end

NS_ASSUME_NONNULL_END
