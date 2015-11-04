//
//  LoggerConfigurator.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLoggerConfigurator.h"
#import "GTLoggerConstants.h"

@implementation GTLoggerConfigurator

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
    }
    return self;
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
