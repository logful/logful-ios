//
//  GTBaseFileManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTBaseFileManager.h"
#import "GTLoggerConstants.h"

#define kFileManagerLockName @"com.getui.log.file.manager.lock"

@interface GTBaseFileManager ()

@property (nonatomic, strong, nonnull) NSFileHandle *fileHandler;
@property (nonatomic, assign) unsigned long long fileSize;
@property (nonatomic, strong, nonnull) NSRecursiveLock *lock;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation GTBaseFileManager

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super initWithFilePath:filePath];
    if (self) {
        self.filePath = filePath;
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = kFileManagerLockName;

        [self createFileHandler];
    }
    return self;
}

- (void)createFileHandler {
    [self.lock lock];

    NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    if (handler == nil) {
        [[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
        handler = [NSFileHandle fileHandleForWritingAtPath:_filePath];
    }
    self.fileHandler = handler;
    self.fileSize = [handler seekToEndOfFile];

    [self.lock unlock];
}

- (void)write:(NSData *)data {
    if (_fileHandler != nil) {
        [self.lock lock];
        @try {
            [_fileHandler writeData:data];
            _fileSize += data.length;
        }
        @catch (NSException *exception) {
            if (SYSTEM_DEBUG_MODE) {
                //NSLog(@"%@", exception);
            }
        }
        @finally {
            [self.lock unlock];
        }
    }
}

- (unsigned long long)available {
    return _fileSize;
}

- (void)flush {
    if (_fileHandler != nil) {
        [_fileHandler synchronizeFile];
    }
}

- (void)close {
    if (_fileHandler != nil) {
        [_fileHandler closeFile];
    }
}

@end
