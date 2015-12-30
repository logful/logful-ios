//
//  CryptoTool.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTCryptoTool.h"
#import "GTDeviceID.h"
#import "GTLogUtil.h"
#import "GTStringUtils.h"
#import "GTSystemConfig.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import <Security/Security.h>

#define PBKDF_ROUND 50
#define AES_KEY_SIZE 32

@interface GTCryptoTool ()

@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSData *errorData;
@property (nonatomic, strong) dispatch_queue_t cryptoQueue;
@property (nonatomic, readonly) CCCryptorRef cryptor;
@property (nonatomic, readonly) SecKeyRef publicKey;
@property (nonatomic, strong) NSData *keyData;
@property (nonatomic, strong) NSData *ivData;
@property (nonatomic, strong) NSString *securityString;

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

+ (void)addPublicKey:(NSString *)base64String {
    [[GTCryptoTool tool] _add_public_key_reference:base64String tag:@"PUBLIC_KEY"];
}

+ (NSData *)encryptAES:(NSData *)data {
    GTCryptoTool *tool = [GTCryptoTool tool];
    NSData *result = [tool _encrypt_aes:data];
    if (result == nil) {
        return tool.errorData;
    }
    return result;
}

+ (NSData *)encryptRSA:(NSData *)data {
    return [[GTCryptoTool tool] _encrypt_rsa:data];
}

+ (NSString *)securityString {
    return [[GTCryptoTool tool] _security_string];
}

- (id)init {
    self = [super init];
    if (self) {
        self.lock = [[NSRecursiveLock alloc] init];

        NSString *password = [GTSystemConfig appKey];
        NSString *salt = [GTDeviceID uid];
        if ([GTStringUtils isEmpty:password] || [GTStringUtils isEmpty:salt]) {
            return nil;
        }
        self.keyData = [self calculateKey:[password dataUsingEncoding:NSUTF8StringEncoding]
                                     salt:[salt dataUsingEncoding:NSUTF8StringEncoding]];

        if (!self.keyData) {
            return nil;
        }

        CCCryptorStatus status = CCCryptorCreate(kCCEncrypt,
                                                 kCCAlgorithmAES128,
                                                 kCCOptionPKCS7Padding | kCCOptionECBMode,
                                                 self.keyData.bytes,
                                                 kCCKeySizeAES256,
                                                 NULL,
                                                 &_cryptor);
        if (status != kCCSuccess || _cryptor == NULL) {
            [GTLogUtil e:NSStringFromClass(self.class) msg:@"Create CCCryptor failed!"];
            return nil;
        }

        self.cryptoQueue = dispatch_queue_create("com.getui.log.crypto", NULL);

        Byte byte[] = {0x00, 0x00};
        self.errorData = [[NSData alloc] initWithBytes:byte length:2];
    }
    return self;
}

- (void)_add_public_key_reference:(NSString *)key tag:(NSString *)tag {
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e - s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSData *data = [[NSData alloc] initWithBase64EncodedString:key
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [self stripPublicKeyHeader:data];
    if (!data) {
        [GTLogUtil e:NSStringFromClass(self.class) msg:@"Strip rsa public key header failed!"];
        return;
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
        return;
    }

    [publicKey removeObjectForKey:(__bridge id) kSecValueData];
    [publicKey removeObjectForKey:(__bridge id) kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id) kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id) kSecAttrKeyType];

    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef) publicKey, (CFTypeRef *) &keyRef);
    if (status != noErr) {
        [GTLogUtil e:NSStringFromClass(self.class) msg:@"Add rsa public ket failed!"];
        return;
    }
    _publicKey = keyRef;
}

- (NSData *)_encrypt_rsa:(NSData *)data {
    if (!data || !_publicKey) {
        return nil;
    }

    __block NSMutableData *result = [NSMutableData data];
    dispatch_sync(_cryptoQueue, ^{
        const uint8_t *srcbuf = (const uint8_t *) [data bytes];
        size_t srclen = (size_t) data.length;

        size_t block_size = SecKeyGetBlockSize(_publicKey) * sizeof(uint8_t);
        void *outbuf = malloc(block_size);
        size_t src_block_size = block_size - 11;

        for (int idx = 0; idx < srclen; idx += src_block_size) {
            size_t data_len = srclen - idx;
            if (data_len > src_block_size) {
                data_len = src_block_size;
            }

            size_t outlen = block_size;
            OSStatus status = noErr;
            status = SecKeyEncrypt(_publicKey,
                                   kSecPaddingPKCS1,
                                   srcbuf + idx,
                                   data_len,
                                   outbuf,
                                   &outlen);
            if (status != 0) {
                [GTLogUtil e:NSStringFromClass(self.class) msg:@"Encrypt with rsa public key failed!"];
                break;
            } else {
                [result appendBytes:outbuf length:outlen];
            }
        }
        free(outbuf);
    });
    return result;
}

- (NSData *)_encrypt_aes:(NSData *)data {
    if (!data || !_cryptor) {
        return _errorData;
    }
    __block NSData *result;
    dispatch_sync(_cryptoQueue, ^{
        size_t bufsize = CCCryptorGetOutputLength(_cryptor, (size_t) data.length, true);
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
    if (!result) {
        [GTLogUtil e:NSStringFromClass(self.class) msg:@"Encrypt data with aes failed!"];
        return _errorData;
    }
    return result;
}

- (NSString *)_security_string {
    if (_securityString != nil) {
        return _securityString;
    }
    _securityString = [[self _encrypt_rsa:_keyData] base64EncodedStringWithOptions:0];
    return _securityString;
}

- (NSData *)calculateKey:(NSData *)password salt:(NSData *)salt {
    NSMutableData *key = [NSMutableData data];
    [key setLength:AES_KEY_SIZE];
    int result = CCKeyDerivationPBKDF(kCCPBKDF2,
                                      password.bytes,
                                      password.length,
                                      salt.bytes,
                                      salt.length,
                                      kCCPRFHmacAlgSHA256,
                                      PBKDF_ROUND,
                                      key.mutableBytes,
                                      key.length);
    if (result == 0) {
        return key;
    }
    return nil;
}

- (NSData *)stripPublicKeyHeader:(NSData *)d_key {
    // Skip ASN.1 public key header
    if (d_key == nil) {
        return (nil);
    }

    unsigned int len = (unsigned int) d_key.length;
    if (!len) {
        return (nil);
    }

    unsigned char *c_key = (unsigned char *) [d_key bytes];
    unsigned int idx = 0;

    if (c_key[idx++] != 0x30) {
        return (nil);
    }

    if (c_key[idx] > 0x80) {
        idx += c_key[idx] - 0x80 + 1;
    } else {
        idx++;
    }

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
        {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
         0x01, 0x05, 0x00};
    if (memcmp(&c_key[idx], seqiod, 15)) {
        return (nil);
    }

    idx += 15;

    if (c_key[idx++] != 0x03) {
        return (nil);
    }

    if (c_key[idx] > 0x80) {
        idx += c_key[idx] - 0x80 + 1;
    } else {
        idx++;
    }

    if (c_key[idx++] != '\0') {
        return (nil);
    }

    // Now make a new NSData from this buffer
    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

- (void)dealloc {
    if (_cryptor) {
        CCCryptorRelease(_cryptor);
    }
}

@end
