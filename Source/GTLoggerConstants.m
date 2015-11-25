//
//  GTLoggerConstants.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLoggerConstants.h"
#import "GTConstants.h"

NSString *const VERBOSE_NAME = @"verbose";
NSString *const DEBUG_NAME = @"debug";
NSString *const INFO_NAME = @"info";
NSString *const WARN_NAME = @"warn";
NSString *const ERROR_NAME = @"error";
NSString *const EXCEPTION_NAME = @"exception";
NSString *const FATAL_NAME = @"fatal";

NSString *const LOG_SYSTEM_DIR_NAME = @"GetuiLog";

NSString *const LOG_DIR_NAME = @"Log";

NSString *const SYSTEM_INFO_FILE_NAME = @"SystemInfo.bin";

NSString *const SYSTEM_CONFIG_FILE_NAME = @"SystemConfig.plist";

NSString *const CRASH_REPORT_FILE_PREFIX = @"crash-report";

NSString *const CRASH_REPORT_DIR_NAME = @"CrashReport";

NSString *const CACHE_DIR_NAME = @"Cache";

NSString *const ATTACHMENT_DIR_NAME = @"Attachment";

NSString *const DEFAULT_LOGGER_NAME = @"app";

NSString *const DEFAULT_MSG_LAYOUT = @"";

NSString *const API_BASE_URL = @"http://demo.logful.aoapp.com:9600";

NSString *const CLIENT_AUTH_URI = @"/oauth/token";

NSString *const UPLOAD_SYSTEM_INFO_URI = @"/log/info/upload";

NSString *const UPLOAD_LOG_FILE_URI = @"/log/file/upload";

NSString *const UPLOAD_CRASH_REPORT_FILE_URI = @"/log/crash/upload";

NSString *const UPLOAD_ATTACHMENT_FILE_URI = @"/log/attachment/upload";

NSString *const USER_PREFERENCE_FILE_NAME = @"Logful.plist";

NSString *const VERSION = @"0.2.0";

NSString *const APP_KEY = @"525b8747323d49078a96e49f0189de98";

NSString *const APP_SECRET = @"02ce8e2adba94ae5a4807e3f12ea34f3";

@implementation GTLoggerConstants

+ (NSString *)logLevelName:(NSInteger)level {
    switch (level) {
        case LEVEL_VERBOSE:
            return VERBOSE_NAME;
        case LEVEL_DEBUG:
            return DEBUG_NAME;
        case LEVEL_INFO:
            return INFO_NAME;
        case LEVEL_WARN:
            return WARN_NAME;
        case LEVEL_ERROR:
            return ERROR_NAME;
        case LEVEL_EXCEPTION:
            return EXCEPTION_NAME;
        case LEVEL_FATAL:
            return FATAL_NAME;
        default:
            return VERBOSE_NAME;
    }
}

+ (NSArray *)defaultRecordLogLevels {
    return @[ @(LEVEL_VERBOSE),
              @(LEVEL_DEBUG),
              @(LEVEL_INFO),
              @(LEVEL_WARN),
              @(LEVEL_ERROR),
              @(LEVEL_EXCEPTION),
              @(LEVEL_FATAL) ];
}

+ (NSArray *)defaultUploadNetworkType {
    return @[ @(NETWORK_TYPE_WIFI), @(NETWORK_TYPE_WWAN) ];
}

@end
