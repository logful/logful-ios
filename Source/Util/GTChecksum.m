//
//  GTChecksum.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTChecksum.h"

#define CHUNK_SIZE 8192
#define TEMPLATE @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x"

@implementation GTChecksum

+ (NSString *)fileMD5:(NSString *)inFilePath {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:inFilePath];
    if (handle == nil) {
        return nil;
    }

    CC_MD5_CTX md5;

    CC_MD5_Init(&md5);

    BOOL done = NO;
    while (!done) {
        @autoreleasepool {
            NSData *fileData = [handle readDataOfLength:CHUNK_SIZE];
            CC_MD5_Update(&md5, [fileData bytes], (int)[fileData length]);
            if ([fileData length] == 0) {
                done = YES;
            };
        }
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *result = [NSString stringWithFormat:TEMPLATE,
                                                  digest[0], digest[1],
                                                  digest[2], digest[3],
                                                  digest[4], digest[5],
                                                  digest[6], digest[7],
                                                  digest[8], digest[9],
                                                  digest[10], digest[11],
                                                  digest[12], digest[13],
                                                  digest[14], digest[15]];
    return result;
}

@end
