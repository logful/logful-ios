//
//  GzipTool.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTGzipTool.h"
#import <zlib.h>

#define kGzipChunkSize 4096

@implementation GTGzipTool

+ (BOOL)compress:(NSString *)inFilePath
     outFilePath:(NSString *)outFilePath
           error:(NSError *__autoreleasing *)error {
    if (inFilePath == nil || outFilePath == nil) {
        return NO;
    }

    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:inFilePath isDirectory:&isDir];
    if (!exists || isDir) {
        return NO;
    }

    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:inFilePath
                                                                                error:error];
    if (!attributes || [attributes[NSFileSize] unsignedIntegerValue] == 0) {
        return NO;
    }

    int level = Z_DEFAULT_COMPRESSION;
    const char *mode = NULL;
    if (level == Z_DEFAULT_COMPRESSION) {
        mode = "w";
    } else {
        mode = [[NSString stringWithFormat:@"w%d", level] UTF8String];
    }

    NSFileHandle *fileHandler = [NSFileHandle fileHandleForReadingAtPath:inFilePath];
    if (fileHandler != nil) {
        gzFile output = gzopen([outFilePath UTF8String], mode);
        int numberOfBytesWritten = 0;

        do {
            @autoreleasepool {
                NSData *data = [fileHandler readDataOfLength:kGzipChunkSize];
                numberOfBytesWritten = gzwrite(output, data.bytes, (unsigned) data.length);
            }
        } while (numberOfBytesWritten == kGzipChunkSize);

        gzclose(output);

        [fileHandler closeFile];

        return YES;
    }

    return NO;
}

@end
