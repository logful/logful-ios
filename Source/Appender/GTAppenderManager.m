//
//  AsyncAppenderManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTAppenderManager.h"
#import "GTAppenderOperation.h"
#import "GTBaseAppender.h"
#import "GTBaseLogEvent.h"
#import "GTBinaryLayout.h"
#import "GTDatabaseManager.h"
#import "GTDateTimeUtil.h"
#import "GTLogFileMeta.h"
#import "GTLogStorage.h"
#import "GTLogUtil.h"
#import "GTLoggerConstants.h"
#import "GTLoggerFactory.h"
#import "GTLruCache.h"
#import "GTMutableDictionary.h"

#define kAppenderQueueName @"com.getui.log.appender.queue"
#define kLogFileNameTemplate @"%@-%@-%@-%d.bin"
#define kStartLogFileFragment 1
#define kLogFileFragmentStep 1
#define kAppenderManagerLockName @"com.getui.log.appender.manager.lock"

@interface GTAppenderManager ()

@property (nonatomic, strong, nonnull) GTMutableDictionary *appenderDictionary;
@property (nonatomic, strong, nonnull) NSOperationQueue *operationQueue;
@property (nonatomic, strong, nonnull) GTLruCache *logEventCache;
@property (nonatomic, strong, nonnull) NSRecursiveLock *lock;

@end

@implementation GTAppenderManager

+ (id)manager {
    static GTAppenderManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)interrupt {
    GTAppenderManager *manager = [GTAppenderManager manager];

    [manager.lock lock];

    NSDictionary *temp = [NSDictionary dictionaryWithDictionary:manager.appenderDictionary];
    [manager.appenderDictionary removeAllObjects];

    for (NSString *key in temp.allKeys) {
        GTAppender *appender = [temp objectForKey:key];
        [GTAppenderManager safeCloseAppender:appender];
    }

    [[GTDatabaseManager manager] closeAllLogFile];

    [manager.lock unlock];
}

+ (void)append:(GTLogEvent *)event {
    GTAppenderManager *manager = [GTAppenderManager manager];
    if ([GTLoggerFactory isOn]) {
        GTAppenderOperation *operation = [[GTAppenderOperation alloc] initWithEvent:event];
        [[manager getOperationQueue] addOperation:operation];
    } else {
        [manager.logEventCache setObject:event forKey:[[NSUUID UUID] UUIDString]];
    }
}

+ (void)readCache {
    [GTLogUtil i:NSStringFromClass(self.class) msg:@"Will read cached log event!"];
    GTAppenderManager *manager = [GTAppenderManager manager];
    NSDictionary *dictionary = [manager.logEventCache values];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[GTLogEvent class]]) {
            GTLogEvent *event = (GTLogEvent *) obj;
            GTAppenderOperation *operation = [[GTAppenderOperation alloc] initWithEvent:event];
            [[manager getOperationQueue] addOperation:operation];
        }
    }];
    [manager.logEventCache removeAllObjects];
}

+ (GTAppender *)appender:(GTLogEvent *)event {
    GTAppenderManager *manager = [GTAppenderManager manager];

    [manager.lock lock];
    NSString *key = [manager appenderKey:event];
    GTAppender *appender = [manager.appenderDictionary objectForKey:key];
    if (appender == nil) {
        // Create new log file appender.
        appender = [manager newAppender:event];
        if (appender != nil) {
            [manager.appenderDictionary setObject:appender forKey:key];
        }
    } else {
        // Log file appender is full.
        if (![appender writeable]) {
            // 1. Stop current log file appender.
            [self safeCloseAppender:appender];

            // 2. Save log file appender meta to db.
            [[GTDatabaseManager manager] closeLogFile:[event getLoggerName]
                                                level:[event getLevel]
                                             fragment:[appender fragment]];

            // 3. Remove log file appender from dictionary.
            [manager.appenderDictionary removeObjectForKey:key];

            // 4. Create new log file appender.
            int fragment = appender.fragment + kLogFileFragmentStep;
            appender = [manager createAppender:event meta:nil fragment:fragment];

            // 5. Set new log file appender for key.
            [manager.appenderDictionary setObject:appender forKey:key];
        }
    }
    [manager.lock unlock];

    return appender;
}

/**
 *  Safe close log file appender.
 *
 *  @param appender Log file appender
 */
+ (void)safeCloseAppender:(GTAppender *)appender {
    __block GTAppender *obj = appender;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            if (![obj writing]) {
                [obj stop];
                break;
            }
        }
    });
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appenderDictionary = [[GTMutableDictionary alloc] init];

        self.logEventCache = [[GTLruCache alloc] init];
        self.logEventCache.countLimit = 100;

        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = kAppenderManagerLockName;
    }
    return self;
}

- (NSOperationQueue *)getOperationQueue {
    if (_operationQueue == nil) {
        GTLoggerConfigurator *config = [GTLoggerFactory config];
        NSInteger queueSize;
        if (config != nil) {
            queueSize = config.activeLogWriter;
        } else {
            queueSize = DEFAULT_ACTIVE_LOG_WRITER;
        }
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = kAppenderQueueName;
        _operationQueue.maxConcurrentOperationCount = queueSize;
    }
    return _operationQueue;
}

/**
 *  Create new log file appender.
 *
 *  @param event Log event
 *
 *  @return New log file appender
 */
- (GTAppender *)newAppender:(GTLogEvent *)event {
    GTAppender *appender;
    int fragment;

    // Find max fragment for give logger name and level today.
    GTLogFileMeta *meta = [[GTDatabaseManager manager] findMaxFragment:event];
    if (meta != nil) {
        fragment = meta.fragment + kLogFileFragmentStep;

        // Log file meta with eof tag, create new log file appender.
        if (meta.eof) {
            appender = [self createAppender:event meta:nil fragment:fragment];
        } else {
            if ([GTLogStorage isLogFile:meta.filename]) {
                GTLoggerConfigurator *config = [GTLoggerFactory config];
                if (config != nil) {
                    unsigned long long fileSize = [GTLogStorage logFileSize:meta.filename];
                    if (fileSize < config.logFileMaxSize) {
                        // Log file not reach capacity.
                        appender = [self createAppender:event meta:meta fragment:meta.fragment];
                    } else {
                        // Log file reach capacity.

                        // 1. Change log file meta state to eof and waitting for upload.
                        [meta setStatus:FILE_STATE_WILL_UPLOAD];
                        [meta setEof:YES];
                        [[GTDatabaseManager manager] saveLogFileMeta:meta];

                        // 2. Create new log file appender.
                        appender = [self createAppender:event meta:nil fragment:fragment];
                    }
                }
            } else {
                // Log file deleted.

                // 1. Change log file meta state to deleted.
                [meta setStatus:FILE_STATE_DELETED];
                [meta setDeleteTime:[GTDateTimeUtil currentTimeMillis]];
                [[GTDatabaseManager manager] saveLogFileMeta:meta];

                // 2. Create new log file appender.
                appender = [self createAppender:event meta:nil fragment:fragment];
            }
        }
    } else {
        fragment = kStartLogFileFragment;
        appender = [self createAppender:event meta:nil fragment:fragment];
    }
    return appender;
}

- (GTAppender *)createAppender:(GTLogEvent *)event meta:(GTLogFileMeta *)meta fragment:(int)fragment {
    NSString *filename = [self generateFilename:event fragment:fragment];
    NSString *filePath = [GTLogStorage logFilePath:filename];
    GTAppender *appender;
    GTLoggerConfigurator *config = [GTLoggerFactory config];
    if (config != nil) {
        appender = [[GTBaseAppender alloc] initWithLoggerName:[event getLoggerName]
                                                     filePath:filePath
                                                       layout:[[GTBinaryLayout alloc] init]
                                                     capacity:config.logFileMaxSize
                                                     fragment:fragment
                                                  ignoreError:YES
                                               immediateFlush:YES];
        if (meta == nil) {
            // Save new log file meta to db.
            meta = [GTLogFileMeta create:event filename:filename fragment:fragment];
            [[GTDatabaseManager manager] saveLogFileMeta:meta];
        }
    }
    return appender;
}

- (NSString *)appenderKey:(GTLogEvent *)event {
    return [NSString stringWithFormat:@"%@-%d", [event getLoggerName], [event getLevel]];
}

/**
 *  Generate log file name.
 *
 *  @param event    Log event
 *  @param fragment file fragment
 *
 *  @return New filename
 */
- (NSString *)generateFilename:(GTLogEvent *)event fragment:(int)fragment {
    return [NSString stringWithFormat:kLogFileNameTemplate,
                                      [event getLoggerName],
                                      [GTDateTimeUtil dateString],
                                      [GTLoggerConstants logLevelName:[event getLevel]],
                                      fragment];
}

@end
