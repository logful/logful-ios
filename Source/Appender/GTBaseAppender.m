//
//  BaseAppender.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/28.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTBaseAppender.h"
#import "GTBaseFileManager.h"
#import "GTBinaryLayout.h"
#import "GTBaseLogEvent.h"
#import "GTBaseErrorHandler.h"

#define kGTBaseAppenderLockName @"com.getui.log.appender.lock"

@interface GTBaseAppender ()

@property (nonatomic, strong, nonnull) NSString *filePath;
@property (nonatomic, assign) BOOL immediateFlush;
@property (nonatomic, strong, nonnull) GTFileManager *fileManager;
@property (nonatomic, strong, nonnull) NSRecursiveLock *lock;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) unsigned long long capacity;
@property (nonatomic, assign) int fragment;
@property (nonatomic, assign) BOOL isWriting;

@end

@implementation GTBaseAppender

- (instancetype)initWithLoggerName:(NSString *)loggerName
                          filePath:(NSString *)filePath
                            layout:(GTLayout *)layout
                          capacity:(unsigned long long)capacity
                          fragment:(int)fragment
                       ignoreError:(BOOL)ignoreError
                    immediateFlush:(BOOL)immediateFlush {
    self = [super initWithLoggerName:loggerName layout:layout ignoreError:ignoreError];
    if (self) {
        self.filePath = filePath;
        self.immediateFlush = immediateFlush;
        self.fileManager = [[GTBaseFileManager alloc] initWithFilePath:filePath];

        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = kGTBaseAppenderLockName;

        self.started = YES;

        self.capacity = capacity;
        self.fragment = fragment;

        self.isWriting = NO;
    }
    return self;
}

- (void)append:(GTLogEvent *)event {
    if (event == nil) {
        return;
    }

    [self.lock lock];
    self.isWriting = YES;
    @try {
        NSData *data = [[self layout] data:event];
        [self.fileManager write:data];
        if (self.immediateFlush) {
            [self.fileManager flush];
        }
    }
    @catch (NSException *exception) {
        [[self hander] error:[exception description]];
    }
    self.isWriting = NO;
    [self.lock unlock];
}

- (int)fragment {
    return _fragment;
}

- (BOOL)writing {
    return _isWriting;
}

- (BOOL)writeable {
    return [_fileManager available] < _capacity;
}

- (void)stop {
    if (self.fileManager != nil) {
        [self.fileManager close];
    }
}

- (BOOL)isStarted {
    return self.started;
}

@end
