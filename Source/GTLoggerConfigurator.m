//
//  LoggerConfigurator.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTBaseSecurityProvider.h"
#import "GTLoggerConfigurator.h"
#import "GTLoggerConstants.h"

@interface GTLoggerConfigurator ()

@property (nonatomic, assign) unsigned long long logFileMaxSize;
@property (nonatomic, strong, nonnull) NSArray *uploadNetworkType;
@property (nonatomic, strong, nonnull) NSArray *uploadLogLevel;
@property (nonatomic, assign) BOOL deleteUploadedLogFile;
@property (nonatomic, assign) int64_t updateSystemFrequency;
@property (nonatomic, assign) NSInteger activeUploadTask;
@property (nonatomic, assign) NSInteger activeLogWriter;
@property (nonatomic, assign) BOOL caughtException;
@property (nonatomic, strong, nonnull) NSString *defaultLoggerName;
@property (nonatomic, strong, nonnull) NSString *defaultMsgLayout;
@property (nonatomic, assign) int screenshotQuality;
@property (nonatomic, assign) float screenshotScale;
@property (nonatomic, strong, nonnull) id<GTSecurityProvider> securityProvider;

@end

@implementation GTLoggerConfigurator

+ (instancetype)configWithBlock:(void (^__nonnull)(ConfiguratorBuilder *))builderBlock {
    NSParameterAssert(builderBlock);

    ConfiguratorBuilder *builder = [[ConfiguratorBuilder alloc] init];

    builderBlock(builder);

    return [builder build];
}

+ (GTLoggerConfigurator *)defaultConfig {
    return [[GTLoggerConfigurator alloc] init];
}

- (int)screenshotQuality {
    if (_screenshotQuality >= 0 && _screenshotQuality <= 100) {
        return _screenshotQuality;
    }
    return DEFAULT_SCREENSHOT_QUALITY;
}

- (float)screenshotScale {
    if (_screenshotScale >= 0.1 && _screenshotScale <= 1) {
        return _screenshotScale;
    }
    return DEFAULT_SCREENSHOT_SCALE;
}

@end

@implementation ConfiguratorBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.logFileMaxSize = DEFAULT_LOG_FILE_MAX_SIZE;
        self.uploadNetworkType = [GTLoggerConstants defaultUploadNetworkType];
        self.uploadLogLevel = [GTLoggerConstants defaultRecordLogLevels];
        self.updateSystemFrequency = DEFAULT_UPDATE_SYSTEM_FREQUENCY;
        self.activeUploadTask = DEFAULT_ACTIVE_UPLOAD_TASK;
        self.activeLogWriter = DEFAULT_ACTIVE_LOG_WRITER;
        self.deleteUploadedLogFile = DEFAULT_DELETE_UPLOADED_LOG_FILE;
        self.caughtException = DEFAULT_CAUGHT_EXCEPTION;
        self.defaultLoggerName = DEFAULT_LOGGER_NAME;
        self.defaultMsgLayout = DEFAULT_MSG_LAYOUT;
        self.screenshotQuality = DEFAULT_SCREENSHOT_QUALITY;
        self.screenshotScale = DEFAULT_SCREENSHOT_SCALE;
        self.securityProvider = [[GTBaseSecurityProvider alloc] init];
    }
    return self;
}

- (GTLoggerConfigurator *)build {
    GTLoggerConfigurator *config = [[GTLoggerConfigurator alloc] init];
    config.logFileMaxSize = _logFileMaxSize;
    config.uploadNetworkType = _uploadNetworkType;
    config.uploadLogLevel = _uploadLogLevel;
    config.updateSystemFrequency = _updateSystemFrequency;
    config.activeUploadTask = _activeUploadTask;
    config.activeLogWriter = _activeLogWriter;
    config.deleteUploadedLogFile = _deleteUploadedLogFile;
    config.caughtException = _caughtException;
    config.defaultLoggerName = _defaultLoggerName;
    config.defaultMsgLayout = _defaultMsgLayout;
    config.screenshotQuality = _screenshotQuality;
    config.screenshotScale = _screenshotScale;
    config.securityProvider = _securityProvider;
    return config;
}

@end
