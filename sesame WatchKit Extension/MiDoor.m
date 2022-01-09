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
#import "NSData+CRC32.h"
#import "InterfaceController.h"
#import "hkdf.h"
#import "aes_ccm.h"

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
//        return [[MiDoor alloc] initWithPassword: [MiDoor hexStringToData: @"6c995fc25f0444dbb21d603be65dc2f59d4b53327b2e299d03cecca43fe73614"] name : @"保险柜"];
    }
    if(productId == 0x492) {
        return [[MiDoor alloc] initWithPassword: [MiDoor hexStringToData: @"f1bfc155c355d27e49ec4dae2f513276ceb4508a75cf9217d427b2a1f3b964d4"] name : @"小米智能锁"];
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

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error == nil && [self.unlockCharacteristic isEqual: characteristic]) {
        [peripheral readValueForCharacteristic: self.notifyCharacteristic];
    }
}

- (void) tryUnlock:(CBPeripheral *)peripheral {
    if(self.lastUnlockDate && [[NSDate now] timeIntervalSinceDate: self.lastUnlockDate] < 15) {
        NSLog(@"tryUnlock waiting door=%@", self);
        NSString *tip = [NSString stringWithFormat: @"%@已开锁", self.name];
        InterfaceController *controller = [InterfaceController sharedController];
        [controller setGuardName: tip];
        return;
    }
    
    [super tryUnlock: peripheral];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if([peripheral state] != CBPeripheralStateConnected) {
        return;
    }
    
    NSData *data = [characteristic value];
    NSLog(@"didUpdateValueForCharacteristic characteristic=%@, value=%@, authState=%d", characteristic, data, self.authState);
    
    if([characteristic isEqual: self.notifyCharacteristic]) {
        if(self.authState == TryUnlock && [data length] == 7) {
            uint16_t seq = 0;
            [data getBytes: &seq length: 2];
            uint32_t n = 0;
            uint32_t seq32 = seq;
            NSData *key = [self.sessionKey subdataWithRange: NSMakeRange(0, 16)];
            NSMutableData *nonce = [NSMutableData dataWithCapacity: 12];
            [nonce appendData: [self.sessionKey subdataWithRange: NSMakeRange(32, 4)]];
            [nonce appendBytes: &n length: 4];
            [nonce appendBytes: &seq32 length: 4];
            NSData *cipher = [data subdataWithRange: NSMakeRange(2, 1)];
            NSData *tag = [data subdataWithRange: NSMakeRange(3, 4)];
            unsigned char plaintext[1];
            memset(plaintext, 0x8, 1);
            int len = decrypt_aes_ccm((unsigned char *) [cipher bytes], (int) [cipher length], (unsigned char *) [tag bytes], (unsigned char *) [key bytes], (unsigned char *) [nonce bytes], plaintext);
            NSLog(@"Test unlock cipher=%@, tag=%@, nonce=%@, len=%d, plaintext=%@", [cipher toHexString], [tag toHexString], [nonce toHexString], len, [[NSData dataWithBytes: plaintext length: 1] toHexString]);
            if(plaintext[0] == 0) {
                self.lastUnlockDate = [NSDate now];
                self.authState = UnlockFinish;
                [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeSuccess];
            }
        }
    }
    
    if([characteristic isEqual: self.authenticationCharacteristic]) {
        if(self.authState == WaitAuthStatus && [data length] == 4) {
            uint32_t status = 0;
            [data getBytes: &status length: 4];
            if(status != 0x21) {
                NSLog(@"Auth failed: 0x%x", status);
            } else {
                self.authState = TryUnlock;
                
                uint16_t seq = 0;
                uint32_t n = 0;
                uint32_t seq32 = seq;
                NSData *key = [self.sessionKey subdataWithRange: NSMakeRange(16, 16)];
                NSMutableData *nonce = [NSMutableData dataWithCapacity: 12];
                [nonce appendData: [self.sessionKey subdataWithRange: NSMakeRange(36, 4)]];
                [nonce appendBytes: &n length: 4];
                [nonce appendBytes: &seq32 length: 4];
                
                unsigned char ciphertext[1];
                memset(ciphertext, 0, 1);
                unsigned char tag[4];
                memset(tag, 0, 4);
                unsigned char data[1];
                memset(data, 0, 1);
                int len = encrypt_aes_ccm((unsigned char *) data, 1, (unsigned char *) [key bytes], (unsigned char *) [nonce bytes], ciphertext, tag);
                NSMutableData *packet = [NSMutableData dataWithCapacity: 7];
                [packet appendBytes: &seq length: 2];
                [packet appendBytes: ciphertext length: 1];
                [packet appendBytes: tag length: 4];
                NSLog(@"Try unlock packet=%@ len=%d, key=%@, nonce=%@", [packet toHexString], len, [key toHexString], [nonce toHexString]);
                
                [peripheral writeValue: packet forCharacteristic: self.unlockCharacteristic type: CBCharacteristicWriteWithResponse];
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
                        EC_KEY *ec_key;
                        EC_KEY *ec_pubkey;
                        EC_KEY *ec_privkey;
                        
                        ec_key = EC_KEY_new_by_curve_name(NID_X9_62_prime256v1);
                        const void * peerPublicKeyData = [self.peerPublicKey bytes];
                        ec_pubkey = o2i_ECPublicKey(&ec_key, (const unsigned char**)&peerPublicKeyData, [self.peerPublicKey length]);
                        const void * privateKeyData = [self.privateKey bytes];
                        ec_privkey = d2i_ECPrivateKey(NULL, (const unsigned char**)&privateKeyData, [self.privateKey length]);
                        NSLog(@"WaitSendAuth ec_key=%p, ec_pubkey=%p, ec_privkey=%p", ec_key, ec_pubkey, ec_privkey);
                        
                        unsigned char buf[1024];
                        const EC_GROUP *group = EC_KEY_get0_group(ec_privkey);
                        int field_size = EC_GROUP_get_degree(group);
                        int secret_len = ECDH_compute_key(buf, (field_size+7)/8, EC_KEY_get0_public_key(ec_pubkey), ec_privkey, NULL);
                        NSData *secretKey = [NSData dataWithBytes: buf length: secret_len];
                        
                        EC_KEY_free(ec_key);
                        EC_KEY_free(ec_privkey);
                        
                        NSMutableData *ikm = [NSMutableData dataWithCapacity: 64];
                        [ikm appendData: secretKey];
                        [ikm appendData: self.password];
                        
                        const char *salt = "smartcfg-login-salt";
                        const char *info = "smartcfg-login-info";
                        unsigned char okm[64];
                        unsigned char *out = HKDF(EVP_sha256(), (const unsigned char *) salt, strlen(salt), [ikm bytes], [ikm length], (const unsigned char *) info, strlen(info), okm, 64);
                        NSData *sessionKey = [NSData dataWithBytes: out length:64];
                        self.sessionKey = sessionKey;
                        NSData *key = [sessionKey subdataWithRange: NSMakeRange(16, 16)];
                        int32_t crc32 = [[self.peerPublicKey subdataWithRange: NSMakeRange(1, 64)] crc32];
                        NSData *buffer = [NSData dataWithBytes: &crc32 length: 4];
                        unsigned char nonce[12];
                        for(uint8_t i = 0; i < 12; i++) {
                            nonce[i] = i + 0x10;
                        }
                        NSData *nonceData = [NSData dataWithBytes: nonce length: 12];
                        unsigned char ciphertext[4];
                        memset(ciphertext, 0, 4);
                        unsigned char tag[4];
                        memset(tag, 0, 4);
                        int len = encrypt_aes_ccm((unsigned char *) [buffer bytes], (int) [buffer length], (unsigned char *) [key bytes], (unsigned char *) [nonceData bytes], ciphertext, tag);
                        NSMutableData *encrypted = [NSMutableData dataWithCapacity: 8];
                        [encrypted appendBytes: ciphertext length: 4];
                        [encrypted appendBytes: tag length: 4];
                        NSLog(@"encrypt_aes_ccm data=%@, key=%@, nonce=%@, len=%d, encrypted=%@", [buffer toHexString], [key toHexString], [nonceData toHexString], len, [encrypted toHexString]);
                        NSLog(@"SendAuth key=%@, buffer=%@, nonce=%@", [key toHexString], [buffer toHexString], [nonceData toHexString]);
                        
                        self.authState = SentAuth;
                        struct batch_packet batch;
                        batch.seq = 1;
                        [encrypted getBytes: batch.buf length: 8];
                        
                        NSData *pp = [NSData dataWithBytes: &batch length: 10];
                        NSLog(@"SendAuth data=%@, ikm=%@, ikm_length=%zu, sessionKey=%@", [pp toHexString], [ikm toHexString], [ikm length], [sessionKey toHexString]);
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
        
        if(self.publicKey == nil || self.privateKey == nil) {
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
        }
        
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
    
    NSLog(@"trySecurityAuth readCharacteristic=%@, authenticationCharacteristic=%@, securityAuthCharacteristic=%@, unlockCharacteristic=%@, notifyCharacteristic=%@", self.readCharacteristic, self.authenticationCharacteristic, self.securityAuthCharacteristic, self.unlockCharacteristic, self.notifyCharacteristic);
    
    InterfaceController *controller = [InterfaceController sharedController];
    [controller setGuardName: self.name];
    
    [peripheral readValueForCharacteristic: self.readCharacteristic];
}

- (NSArray<CBUUID *> *) characteristicUUIDs:(CBService *)service {
    CBUUID *miService = [MiDoor MI_SERVICE_UUID];
    if([miService isEqual: [service UUID]]) {
        const CBUUID *READ_UUID = [CBUUID UUIDWithString: @"00000004-0000-1000-8000-00805f9b34fb"];
        const CBUUID *AUTHENTICATION_UUID = [CBUUID UUIDWithString: @"00000010-0000-1000-8000-00805f9b34fb"];
        const CBUUID *SECURITY_AUTH_UUID = [CBUUID UUIDWithString: @"00000016-0000-1000-8000-00805f9b34fb"];
        return [NSArray arrayWithObjects: READ_UUID, AUTHENTICATION_UUID, SECURITY_AUTH_UUID, nil];
    }
    CBUUID *lockService = [CBUUID UUIDWithString: @"00001000-0065-6c62-2e74-6f696d2e696d"];
    if([lockService isEqual: [service UUID]]) {
        const CBUUID *UNLOCK_UUID = [CBUUID UUIDWithString: @"00001001-0065-6c62-2e74-6f696d2e696d"];
        const CBUUID *LOCK_NOTIFY_UUID = [CBUUID UUIDWithString: @"00001002-0065-6c62-2e74-6f696d2e696d"];
        return [NSArray arrayWithObjects: UNLOCK_UUID, LOCK_NOTIFY_UUID, nil];
    }
    return [super characteristicUUIDs: service];
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

- (NSArray<CBUUID *> *)serviceUUIDs {
    CBUUID *miService = [MiDoor MI_SERVICE_UUID];
    CBUUID *lockService = [CBUUID UUIDWithString: @"00001000-0065-6c62-2e74-6f696d2e696d"];
    return [NSArray arrayWithObjects: miService, lockService, nil];
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
    
    self.peerPublicKey = nil;
    self.sessionKey = nil;
    self.authState = Start;
    
    NSArray<CBService *> *services = [peripheral services];
    NSArray<CBUUID *> *array = [self serviceUUIDs];
    for(CBService *service in services) {
        CBUUID *uuid = [service UUID];
        if([array containsObject: uuid]) {
            [peripheral discoverCharacteristics: [self characteristicUUIDs: service] forService:service];
        }
    }
}

@end
