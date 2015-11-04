//
//  CryptoTool.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTCryptoTool.h"
#import <openssl/evp.h>
#import <stdio.h>
#import <stdlib.h>

#define KEY_PREFIX @"A8P20vWlvfSu3JMO6tBjgr05UvjHAh2x"
#define CRYPTO_ERROR @"CRYPTO_ERROR"

const EVP_CIPHER *cipher;
const EVP_MD *dgst = NULL;
const unsigned char *salt = NULL;

@interface GTCryptoTool ()

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSData *key;
@property (nonatomic, strong) NSData *iv;

@end

@implementation GTCryptoTool

+ (id)tool {
    static GTCryptoTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] init];
    });
    return tool;
}

+ (NSString *)encrypt:(NSString *)string {
    GTCryptoTool *tool = [GTCryptoTool tool];
    if (tool.key == nil || tool.iv == nil) {
        [tool generateKey];
    }

    return [tool encrypt:[string UTF8String]];
}

- (id)init {
    self = [super init];
    if (self) {
        self.lock = [[NSRecursiveLock alloc] init];
        [self generateKey];
    }
    return self;
}

- (BOOL)generateKey {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *keyString = [NSString stringWithFormat:@"%@%@", bundleId, KEY_PREFIX];
    NSString *keyBase64 = [[keyString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];

    const char *key_char = [keyBase64 UTF8String];

    unsigned char key[EVP_MAX_KEY_LENGTH];
    unsigned char iv[EVP_MAX_IV_LENGTH];

    OpenSSL_add_all_algorithms();

    cipher = EVP_get_cipherbyname("aes-256-cbc");
    dgst = EVP_get_digestbyname("md5");

    if (!cipher) {
        return NO;
    }

    if (!dgst) {
        return NO;
    }

    if (!EVP_BytesToKey(cipher, dgst, salt,
                        (unsigned char *) key_char,
                        (int) strlen(key_char), 1, key, iv)) {
        return NO;
    }

    self.key = [NSData dataWithBytes:key length:64];
    self.iv = [NSData dataWithBytes:iv length:16];

    EVP_cleanup();

    return YES;
}

- (NSString *)encrypt:(const char *)input {
    [self.lock lock];

    int input_len;
    unsigned char *cipher_text;

    EVP_CIPHER_CTX ctx;
    EVP_CIPHER_CTX_init(&ctx);

    if (!EVP_EncryptInit_ex(&ctx, EVP_aes_256_cbc(), NULL, self.key.bytes, self.iv.bytes)) {
        return CRYPTO_ERROR;
    };

    input_len = (int) strlen(input) + 1;
    cipher_text = (unsigned char *) malloc(input_len + EVP_CIPHER_CTX_block_size(&ctx));

    int bytes_written = 0;
    int ciphertext_len = 0;
    if (!EVP_EncryptUpdate(&ctx, cipher_text, &bytes_written, (unsigned const char *) input, input_len)) {
        return CRYPTO_ERROR;
    };
    ciphertext_len += bytes_written;

    if (!EVP_EncryptFinal_ex(&ctx, cipher_text + bytes_written, &bytes_written)) {
        return CRYPTO_ERROR;
    };
    ciphertext_len += bytes_written;

    EVP_CIPHER_CTX_cleanup(&ctx);

    NSData *data = [NSData dataWithBytes:cipher_text length:ciphertext_len];
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    NSString *len_string = [NSString stringWithFormat:@"%d__%@", ciphertext_len, base64];

    NSData *result_data = [len_string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *result = [result_data base64EncodedStringWithOptions:0];

    free(cipher_text);

    [self.lock unlock];

    return result;
}

@end
