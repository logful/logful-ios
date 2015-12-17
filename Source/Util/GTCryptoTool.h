//
//  CryptoTool.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface GTCryptoTool : NSObject

+ (SecKeyRef)addPublicKey:(NSString *)base64String tag:(NSString *)tag;

+ (NSData *)encryptAES:(NSData *)data;
+ (NSData *)encryptRSA:(NSData *)data withKeyRef:(SecKeyRef)keyRef;

@end
