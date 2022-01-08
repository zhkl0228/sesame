//
//  MiDoor.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2022/1/7.
//  Copyright © 2022 廖正凯. All rights reserved.
//

#import <openssl/crypto.h>
#import <openssl/evp.h>
#import <openssl/ec.h>
#import <openssl/ecdh.h>

#import "MiDoor.h"
#import "NSData+Hex.h"
#import "InterfaceController.h"

const uint8_t COMMAND_FLOW = 0;
const uint8_t COMMAND_ACK = 1;

struct flow_packet {
    uint16_t header;
    uint8_t command;
    uint8_t packet_type;
    uint16_t frame_count;
};

struct ack_packet {
    uint16_t header;
    uint8_t command;
    uint8_t status;
};

struct batch_packet {
    uint16_t seq;
    char buf[18];
};

@implementation MiDoor

+ (CBUUID *) MI_SERVICE_UUID {
    return [CBUUID UUIDWithString: @"0000fe95-0000-1000-8000-00805f9b34fb"];
}

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
        return [[MiDoor alloc] initWithPassword: [MiDoor hexStringToData: @"6c995fc25f0444dbb21d603be65dc2f59d4b53327b2e299d03cecca43fe73614"] name : @"保险柜"];
    }
    return nil;
}

- (MiDoor *) initWithPassword: (NSData *) _password name : (NSString *) _name {
    if((self = [super init])) {
        self.name = _name;
        self.password = _password;
    }
    return self;
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic characteristic=%@", characteristic);
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if([peripheral state] != CBPeripheralStateConnected) {
        return;
    }
    
    NSData *data = [characteristic value];
    NSLog(@"didUpdateValueForCharacteristic characteristic=%@, value=%@, authState=%d", characteristic, data, self.authState);
    
    if([characteristic isEqual: self.authenticationCharacteristic]) {
        if(self.authState == WaitAuthStatus && [data length] == 4) {
            uint32_t status = 0;
            [data getBytes: &status length: 4];
            if(status != 0x21) {
                NSLog(@"Auth failed: 0x%x", status);
            }
        }
    }
    
    struct ack_packet ack;
    struct flow_packet flow;
        
    if([characteristic isEqual: self.securityAuthCharacteristic]) {
        switch (self.authState) {
            case WaitSendPublicKey:
                if([data length] == sizeof(ack)) {
                    [data getBytes: &ack length: sizeof(ack)];
                    if(ack.command == COMMAND_ACK && ack.status == 1) { // send public key and wait finish
                        self.authState = SentPublicKey;
                        struct batch_packet batch;
                        for(uint8_t i = 0; i < 4; i++) {
                            batch.seq = i + 1;
                            NSUInteger len = 18;
                            if(i == 3) {
                                len = 10;
                            }
                            NSRange range = NSMakeRange(i * 18 + 1, len);
                            [self.publicKey getBytes: batch.buf range: range];
                            NSData *pp = [NSData dataWithBytes: &batch length: len + 2];
                            NSLog(@"SendPublicKey data=%@", [pp toHexString]);
                            [peripheral writeValue: pp forCharacteristic: self.securityAuthCharacteristic type: CBCharacteristicWriteWithoutResponse];
                        }
                    }
                }
                break;
            case SentPublicKey:
                if([data length] == sizeof(ack)) {
                    [data getBytes: &ack length: sizeof(ack)];
                    if(ack.command == COMMAND_ACK && ack.status == 0) { // send public key finish
                        self.authState = WaitReceivePublicKey;
                    }
                }
                break;
            case WaitReceivePublicKey:
                if([data length] == sizeof(flow)) {
                    [data getBytes: &flow length: sizeof(flow)];
                    if(flow.command == COMMAND_FLOW && flow.packet_type == 0x3 && flow.frame_count == 4) {
                        self.authState = ReceivePublicKey;
                        self.peerPublicKey = [NSMutableData dataWithCapacity: 65];
                        uint8_t magic = 0x4;
                        [self.peerPublicKey appendBytes: &magic length: 1];
                        
                        ack.command = COMMAND_ACK;
                        ack.status = 1;
                        NSData *pp = [NSData dataWithBytes: &ack length: sizeof(ack)];
                        [peripheral writeValue: pp forCharacteristic: self.securityAuthCharacteristic type: CBCharacteristicWriteWithoutResponse];
                    }
                }
                break;
            case ReceivePublicKey: {
                uint16_t seq = 0;
                [data getBytes: &seq length: 2];
                NSData *sub = [data subdataWithRange: NSMakeRange(2, [data length] - 2)];
                [self.peerPublicKey appendData: sub];
                if(seq == 4) { // Receive public key success.
                    self.authState = WaitSendAuth;
                    
                    NSLog(@"peerPublicKey=%@, len=%zu", [self.peerPublicKey toHexString], [self.peerPublicKey length]);
                    
                    ack.command = COMMAND_ACK;
                    ack.status = 0;
                    NSData *pp = [NSData dataWithBytes: &ack length: sizeof(ack)];
                    [peripheral writeValue: pp forCharacteristic: self.securityAuthCharacteristic type: CBCharacteristicWriteWithoutResponse];
                    
                    flow.header = 0;
                    flow.command = COMMAND_FLOW;
                    flow.packet_type = 0x5;
                    flow.frame_count = 1;
                    NSData *askFlawPacket = [NSData dataWithBytes: &flow length: sizeof(flow)];
                    [peripheral writeValue: askFlawPacket forCharacteristic: self.securityAuthCharacteristic type: CBCharacteristicWriteWithoutResponse];
                }
                break;
            }
            case WaitSendAuth: {
                if([data length] == sizeof(ack)) {
                    [data getBytes: &ack length: sizeof(ack)];
                    if(ack.command == COMMAND_ACK && ack.status == 1) { // send auth and wait finish
                        self.authState = SentAuth;
                        struct batch_packet batch;
                        batch.seq = 1;
                        
                        NSData *pp = [NSData dataWithBytes: &batch length: 10];
                        NSLog(@"SendAuth data=%@", [pp toHexString]);
                        [peripheral writeValue: pp forCharacteristic: self.securityAuthCharacteristic type: CBCharacteristicWriteWithoutResponse];
                    }
                }
                break;
            }
            case SentAuth: {
                if([data length] == sizeof(ack)) {
                    [data getBytes: &ack length: sizeof(ack)];
                    if(ack.command == COMMAND_ACK && ack.status == 0) { // send auth finish
                        self.authState = WaitAuthStatus;
                    }
                }
                break;
            }
            default:
                NSLog(@"Not handler: state=%d", self.authState);
                break;
        }
    }
    
    if([characteristic isEqual: self.readCharacteristic]) {
        if(self.authState != Start) {
            return;
        }
        
        NSLog(@"didUpdateValueForCharacteristic versionName=%s", (const char *)[data bytes]);
        
        uint32_t security_chip_login_step3_data = 0x20;
        NSData *step3_data = [NSData dataWithBytes: &security_chip_login_step3_data length:4];
        [peripheral writeValue: step3_data forCharacteristic: self.authenticationCharacteristic type: CBCharacteristicWriteWithoutResponse];
        
        EC_KEY *ec_key = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
        EC_KEY_set_asn1_flag(ec_key, OPENSSL_EC_NAMED_CURVE);
        EC_KEY_generate_key(ec_key);
        
        unsigned char buf[1024];
        unsigned char *pp;
        size_t len;
        
        pp = buf;
        len = i2d_ECPrivateKey(ec_key, &pp);
        NSData *private_key = [NSData dataWithBytes: buf length: len];
        NSLog(@"generateKeyPair privateKey=%@, len=%zu", [private_key toHexString], len);
        
        pp = buf;
        len = i2o_ECPublicKey(ec_key, &pp);
        NSData *public_key = [NSData dataWithBytes: buf length: len];
        NSLog(@"generateKeyPair publicKey=%@, len=%zu", [public_key toHexString], len);
        
        EC_KEY_free(ec_key);
        
        self.publicKey = public_key;
        self.privateKey = private_key;
        
        self.authState = WaitSendPublicKey;
        flow.header = 0;
        flow.command = COMMAND_FLOW;
        flow.packet_type = 0x3;
        flow.frame_count = 4; // public key split 4 frame
        NSData *askFlawPacket = [NSData dataWithBytes: &flow length: sizeof(flow)];
        [peripheral writeValue: askFlawPacket forCharacteristic: self.securityAuthCharacteristic type: CBCharacteristicWriteWithoutResponse];
    }
}

- (void) trySecurityAuth: (CBPeripheral *)peripheral {
    if([peripheral state] != CBPeripheralStateConnected) {
        return;
    }
    
    [peripheral setNotifyValue:YES forCharacteristic:self.securityAuthCharacteristic];
    [peripheral setNotifyValue:YES forCharacteristic:self.authenticationCharacteristic];
    [peripheral setNotifyValue:YES forCharacteristic:self.notifyCharacteristic];
    
    NSLog(@"trySecurityAuth readCharacteristic=%@, authenticationCharacteristic=%@, securityAuthCharacteristic=%@, unlockCharacteristic=%@, notifyCharacteristic=%@", self.readCharacteristic, self.authenticationCharacteristic, self.securityAuthCharacteristic, self.unlockCharacteristic, self.notifyCharacteristic);
    
    InterfaceController *controller = [InterfaceController sharedController];
    [controller setGuardName: self.name];
    
    [peripheral readValueForCharacteristic: self.readCharacteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    NSLog(@"didDiscoverCharacteristicsForService peripheral=%@, service=%@, error=%@", peripheral, service, error);
    
    if([peripheral state] != CBPeripheralStateConnected) {
        return;
    }
    
    const CBUUID *READ_UUID = [CBUUID UUIDWithString: @"00000004-0000-1000-8000-00805f9b34fb"];
    const CBUUID *AUTHENTICATION_UUID = [CBUUID UUIDWithString: @"00000010-0000-1000-8000-00805f9b34fb"];
    const CBUUID *SECURITY_AUTH_UUID = [CBUUID UUIDWithString: @"00000016-0000-1000-8000-00805f9b34fb"];
    
    const CBUUID *UNLOCK_UUID = [CBUUID UUIDWithString: @"00001001-0065-6c62-2e74-6f696d2e696d"];
    const CBUUID *LOCK_NOTIFY_UUID = [CBUUID UUIDWithString: @"00001002-0065-6c62-2e74-6f696d2e696d"];
    
    NSArray<CBCharacteristic *> *characteristics = [service characteristics];
    for(CBCharacteristic *characteristic in characteristics) {
        CBUUID *u = [characteristic UUID];
        if([u isEqual:READ_UUID]) {
            self.readCharacteristic = characteristic;
            continue;
        }
        if([u isEqual:AUTHENTICATION_UUID]) {
            self.authenticationCharacteristic = characteristic;
            continue;
        }
        if([u isEqual:SECURITY_AUTH_UUID]) {
            self.securityAuthCharacteristic = characteristic;
            continue;
        }
        if([u isEqual:UNLOCK_UUID]) {
            self.unlockCharacteristic = characteristic;
            continue;
        }
        if([u isEqual:LOCK_NOTIFY_UUID]) {
            self.notifyCharacteristic = characteristic;
            continue;
        }
    }
    
    if(self.readCharacteristic && self.authenticationCharacteristic && self.securityAuthCharacteristic && self.unlockCharacteristic && self.notifyCharacteristic) {
        [self trySecurityAuth: peripheral];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices peripheral=%@, error=%@", peripheral, error);
    
    if([peripheral state] != CBPeripheralStateConnected) {
        return;
    }
    self.readCharacteristic = nil;
    self.authenticationCharacteristic = nil;
    self.securityAuthCharacteristic = nil;
    self.unlockCharacteristic = nil;
    self.notifyCharacteristic = nil;
    
    self.publicKey = nil;
    self.privateKey = nil;
    self.peerPublicKey = nil;
    self.authState = Start;
    
    NSArray<CBService *> *services = [peripheral services];
    for(CBService *service in services) {
        CBUUID *uuid = [service UUID];
        if([uuid isEqual:[MiDoor MI_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:nil forService:service];
            continue;
        }
        if([uuid isEqual: [CBUUID UUIDWithString: @"00001000-0065-6c62-2e74-6f696d2e696d"]]) { // lock control service
            [peripheral discoverCharacteristics:nil forService:service];
            continue;
        }
    }
}

@end
