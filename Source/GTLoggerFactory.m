//
//  LoggerFactory.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLoggerFactory.h"
#import "GTBaseLogger.h"
#import "GTMutableDictionary.h"
#import "GTDatabaseManager.h"
#import "GTLoggerConstants.h"
#import "GTAppenderManager.h"
#import "GTLogStorage.h"
#import "GTScheduleManager.h"
#import "GTTransferManager.h"
#import "GTUncaughtExceptionHandler.h"
#import "GTDatabaseManager.h"
#import "GTSystemConfig.h"
#import "GTStringUtils.h"
#import "GTCaptureTool.h"
#import "GTClientAuthUtil.h"

@interface GTLoggerFactory ()

@property (nonatomic, strong) GTMutableDictionary *loggerCache;
@property (nonatomic, strong) GTLoggerConfigurator *config;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, assign) BOOL initialized;

@end

@implementation GTLoggerFactory

+ (instancetype)factory {
    static GTLoggerFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[self alloc] init];
    });
    return factory;
}

+ (void)init {
    GTLoggerConfigurator *config = [GTLoggerConfigurator defaultConfig];
    [GTLoggerFactory initWithConfig:config];
}

+ (void)initWithConfig:(GTLoggerConfigurator *)config {
    if (config == nil) {
        return;
    }
    GTLoggerFactory *instance = [GTLoggerFactory factory];
    instance.config = config;
    [instance initSystem];
}

+ (NSString *)version {
    return VERSION;
}

+ (GTLogger *)logger:(NSString *)loggerName {
    return [[GTLoggerFactory factory] getLogger:loggerName];
}

+ (GTLoggerConfigurator *)config {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    return factory.config;
}

+ (void)setApiUrl:(NSString *)url {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    if (factory.initialized) {
        [GTSystemConfig saveBaseUrl:url];
    }
}

+ (void)bindAlias:(NSString *)alias {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    if (factory.initialized) {
        [GTSystemConfig saveAlias:alias];
    }
}

+ (void)turnOn {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    if (factory.initialized) {
        [GTSystemConfig saveStatus:YES];

        [GTAppenderManager readCache];
    }
}

+ (void)turnOff {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    if (factory.initialized) {
        [GTSystemConfig saveStatus:NO];
    }
}

+ (BOOL)isOn {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    return factory.initialized && [GTSystemConfig isON];
}

+ (void)sync {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    if (factory.initialized) {
        [GTTransferManager uploadLogFile];
        [GTTransferManager uploadAttachment];
    }
}

+ (void)sync:(uint64_t)startTime endTime:(uint64_t)endTime {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    if (factory.initialized) {
        [GTTransferManager uploadLogFile:startTime endTime:endTime];
        [GTTransferManager uploadAttachment];
    }
}

+ (void)interruptThenSync {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    if (factory.initialized) {
        [GTAppenderManager interrupt];
        [GTTransferManager uploadLogFile];
        [GTTransferManager uploadAttachment];
    }
}

+ (GTLogger *)defaultLogger {
    GTLoggerFactory *factory = [GTLoggerFactory factory];
    return [factory getLogger:[factory defaultLoggerName]];
}

void GLOG_VERBOSE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] verbose:tag msg:msg];
}

void GLOG_VERBOSE_CAPTURE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] verbose:tag msg:msg capture:YES];
}

void GLOG_DEBUG(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] debug:tag msg:msg];
}

void GLOG_DEBUG_CAPTURE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] debug:tag msg:msg capture:YES];
}

void GLOG_INFO(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] info:tag msg:msg];
}

void GLOG_INFO_CAPTURE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] info:tag msg:msg capture:YES];
}

void GLOG_WARN(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] warn:tag msg:msg];
}

void GLOG_WARN_CAPTURE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] warn:tag msg:msg capture:YES];
}

void GLOG_ERROR(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] error:tag msg:msg];
}

void GLOG_ERROR_CAPTURE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] error:tag msg:msg capture:YES];
}

void GLOG_EXCEPTION(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] exception:tag msg:msg];
}

void GLOG_EXCEPTION_CAPTURE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] exception:tag msg:msg capture:YES];
}

void GLOG_FATAL(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] fatal:tag msg:msg];
}

void GLOG_FATAL_CAPTURE(NSString *tag, NSString *msg) {
    [[GTLoggerFactory defaultLogger] fatal:tag msg:msg capture:YES];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.initialized = NO;
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"com.getui.log.factory.lock";
    }
    return self;
}

/**
 *  Init log system
 */
- (void)initSystem {

    [_lock lock];

    if (_initialized) {
        [_lock unlock];
        return;
    }

    _loggerCache = [[GTMutableDictionary alloc] init];

    // Init log system storage.
    [GTLogStorage initStorage];

    // Read system config file.
    [GTSystemConfig read];

    // Init database.
    [GTDatabaseManager manager];

    // Catch uncaught exception.
    if (_config.caughtException) {
        SetUncaughtExceptionHandler();
    }

    _initialized = YES;

    [_lock unlock];

    if ([GTSystemConfig isON]) {
        // Read log event cache.
        [GTAppenderManager readCache];
    }

    [GTClientAuthUtil authenticate];
}

- (GTLogger *)getLogger:(NSString *)loggerName {
    if (loggerName == nil) {
        return nil;
    }
    GTLogger *logger = [_loggerCache objectForKey:loggerName];
    if (logger == nil) {
        logger = [[GTBaseLogger alloc] initWithName:loggerName];
        [logger setMsgLayout:[self defaultMsgLayout]];
        [_loggerCache setObject:logger forKey:loggerName];
    }
    return logger;
}

- (NSString *)defaultLoggerName {
    if (_config == nil) {
        return DEFAULT_LOGGER_NAME;
    }
    if ([GTStringUtils isEmpty:_config.defaultLoggerName]) {
        return DEFAULT_LOGGER_NAME;
    }
    return _config.defaultLoggerName;
}

- (NSString *)defaultMsgLayout {
    if (_config == nil) {
        return DEFAULT_MSG_LAYOUT;
    }
    if ([GTStringUtils isEmpty:_config.defaultMsgLayout]) {
        return DEFAULT_MSG_LAYOUT;
    }
    return _config.defaultMsgLayout;
}

@end
