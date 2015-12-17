//
//  CryptoTool.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTCryptoTool.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>

#define CRYPTO_ERROR @"CRYPTO_ERROR"

@interface GTCryptoTool ()

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSData *errorData;
@property (nonatomic, strong) dispatch_queue_t cryptoQueue;
@property (nonatomic, readonly) CCCryptorRef cryptor;

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

+ (SecKeyRef)addPublicKey:(NSString *)base64String tag:(NSString *)tag {
    return [[GTCryptoTool tool] _add_public_key_reference:base64String tag:tag];
}

+ (NSData *)encryptAES:(NSData *)data {
    GTCryptoTool *tool = [GTCryptoTool tool];
    NSData *result = [tool _encrypt_aes:data];
    if (result == nil) {
        return tool.errorData;
    }
    NSLog(@"%zd == %@", result.length, result);
    return result;
}

+ (NSData *)encryptRSA:(NSData *)data withKeyRef:(SecKeyRef)keyRef {
    return [[GTCryptoTool tool] _encrypt_rsa:data withKeyRef:keyRef];
}

- (id)init {
    self = [super init];
    if (self) {
        self.lock = [[NSRecursiveLock alloc] init];
        //[self generateKey];

        //NSString *key = @"9rX5eh941YCrusrohrCizRa5WwwDOesW";
        //char keyPtr[kCCKeySizeAES256 + 1];
        //bzero(keyPtr, sizeof(keyPtr));
        //[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

        /*
        char ivPtr[kCCKeySizeAES256 + 1];
        memset(ivPtr, 0, sizeof(ivPtr));
         */

        NSData *key = [@"9rX5eh941YCrusrohrCizRa5WwwDOesW" dataUsingEncoding:NSUTF8StringEncoding];
        CCCryptorStatus status = CCCryptorCreate(kCCEncrypt,
                                                 kCCAlgorithmAES128,
                                                 kCCOptionPKCS7Padding,
                                                 key.bytes,
                                                 key.length,
                                                 NULL,
                                                 &_cryptor);
        if (status != kCCSuccess || _cryptor == NULL) {
            return nil;
        }
        self.cryptoQueue = dispatch_queue_create("com.getui.log.crypto", NULL);
        self.errorData = [CRYPTO_ERROR dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (SecKeyRef)_add_public_key_reference:(NSString *)key tag:(NSString *)tag {
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSData *data = [[NSData alloc] initWithBase64EncodedString:key
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [self stripPublicKeyHeader:data];
    if (!data) {
        return nil;
    }

    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id) kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id) kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id) kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef) publicKey);

    [publicKey setObject:data forKey:(__bridge id) kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id) kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id) kSecReturnPersistentRef];

    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef) publicKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }

    [publicKey removeObjectForKey:(__bridge id) kSecValueData];
    [publicKey removeObjectForKey:(__bridge id) kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id) kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id) kSecAttrKeyType];

    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef) publicKey, (CFTypeRef *) &keyRef);
    if (status != noErr) {
        return nil;
    }
    return keyRef;
}

- (NSData *)_encrypt_rsa:(NSData *)data withKeyRef:(SecKeyRef)keyRef {
    if (!data || !keyRef) {
        return nil;
    }

    const uint8_t *srcbuf = (const uint8_t *) [data bytes];
    size_t srclen = (size_t) data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;

    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }

        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef,
                               kSecPaddingPKCS1,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen);
        if (status != 0) {
            ret = nil;
            break;
        } else {
            [ret appendBytes:outbuf length:outlen];
        }
    }

    free(outbuf);
    CFRelease(keyRef);

    return ret;
}

- (NSData *)_encrypt_aes:(NSData *)data {
    __block NSData *result;
    dispatch_sync(_cryptoQueue, ^{
        size_t bufsize = CCCryptorGetOutputLength(_cryptor, (size_t)[data length], true);
        void *buffer = malloc(bufsize);
        size_t dataOutMoved = 0;
        size_t cipherLength = 0;
        CCCryptorStatus status = CCCryptorUpdate(_cryptor,
                                                 data.bytes,
                                                 (size_t) data.length,
                                                 buffer,
                                                 bufsize,
                                                 &dataOutMoved);
        if (status == kCCSuccess) {
            cipherLength += dataOutMoved;
            status = CCCryptorFinal(_cryptor,
                                    buffer + dataOutMoved,
                                    bufsize - dataOutMoved,
                                    &dataOutMoved);
            if (status == kCCSuccess) {
                cipherLength += dataOutMoved;
                result = [NSData dataWithBytesNoCopy:buffer length:cipherLength freeWhenDone:YES];
            } else {
                free(buffer);
            }
        } else {
            free(buffer);
        }
    });
    return result;
}

- (NSData *)stripPublicKeyHeader:(NSData *)d_key {
    // Skip ASN.1 public key header
    if (d_key == nil)
        return (nil);

    unsigned int len = (unsigned int) d_key.length;
    if (!len)
        return (nil);

    unsigned char *c_key = (unsigned char *) [d_key bytes];
    unsigned int idx = 0;

    if (c_key[idx++] != 0x30)
        return (nil);

    if (c_key[idx] > 0x80)
        idx += c_key[idx] - 0x80 + 1;
    else
        idx++;

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
        {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
         0x01, 0x05, 0x00};
    if (memcmp(&c_key[idx], seqiod, 15))
        return (nil);

    idx += 15;

    if (c_key[idx++] != 0x03)
        return (nil);

    if (c_key[idx] > 0x80)
        idx += c_key[idx] - 0x80 + 1;
    else
        idx++;

    if (c_key[idx++] != '\0')
        return (nil);

    // Now make a new NSData from this buffer
    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

- (void)dealloc {
    if (_cryptor) {
        CCCryptorRelease(_cryptor);
    }
}

@end
