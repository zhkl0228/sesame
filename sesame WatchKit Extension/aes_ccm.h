//
//  aes_ccm.h
//  sesame
//
//  Created by LiaoZhengKai on 2022/1/8.
//  Copyright © 2022 廖正凯. All rights reserved.
//

#ifndef aes_ccm_h
#define aes_ccm_h

int encrypt_aes_ccm(unsigned char *plaintext, int plaintext_len,
                unsigned char *key,
                unsigned char *iv,
                unsigned char *ciphertext,
                unsigned char *tag);

int decrypt_aes_ccm(unsigned char *ciphertext, int ciphertext_len,
                unsigned char *tag,
                unsigned char *key,
                unsigned char *iv,
                unsigned char *plaintext);

#endif /* aes_ccm_h */
