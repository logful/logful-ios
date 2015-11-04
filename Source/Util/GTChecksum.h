//
//  GTChecksum.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface GTChecksum : NSObject

+ (NSString *)fileMD5:(NSString *)inFilePath;

@end
