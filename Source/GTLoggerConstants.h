//
//  GTLoggerConstants.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

// Log level name string.
extern NSString *const VERBOSE_NAME;
extern NSString *const DEBUG_NAME;
extern NSString *const INFO_NAME;
extern NSString *const WARN_NAME;
extern NSString *const ERROR_NAME;
extern NSString *const EXCEPTION_NAME;
extern NSString *const FATAL_NAME;

// 日志系统存储文件夹.
extern NSString *const LOG_SYSTEM_DIR_NAME;

// 日志文件存储文件夹名称.
extern NSString *const LOG_DIR_NAME;

// 环境信息存储文件名称.
extern NSString *const SYSTEM_INFO_FILE_NAME;

// 系统配置文件名称.
extern NSString *const SYSTEM_CONFIG_FILE_NAME;

// 崩溃日志记录文件名称前缀.
extern NSString *const CRASH_REPORT_FILE_PREFIX;

// 崩溃日志文件存储文件夹.
extern NSString *const CRASH_REPORT_DIR_NAME;

// 日志系统缓存存储文件夹.
extern NSString *const CACHE_DIR_NAME;

// 附件存储文件夹.
extern NSString *const ATTACHMENT_DIR_NAME;

// 默认 logger 名称.
extern NSString *const DEFAULT_LOGGER_NAME;

// 默认日志内容模板.
extern NSString *const DEFAULT_MSG_LAYOUT;

// api url base.
extern NSString *const API_BASE_URL;

// 客户端授权 api.
extern NSString *const CLIENT_AUTH_URI;

// 系统环境信息文件上传 api.
extern NSString *const UPLOAD_SYSTEM_INFO_URI;

// 日志文件上传 api.
extern NSString *const UPLOAD_LOG_FILE_URI;

// 崩溃日志文件上传 api.
extern NSString *const UPLOAD_CRASH_REPORT_FILE_URI;

// 上传附件文件 api.
extern NSString *const UPLOAD_ATTACHMENT_FILE_URI;

// 用户配置文件名称.
extern NSString *const USER_PREFERENCE_FILE_NAME;

// 当前日志库版本.
extern NSString *const VERSION;

extern NSString *const APP_KEY;

extern NSString *const APP_SECRET;

// 默认同时上传任务数.
static NSInteger DEFAULT_ACTIVE_UPLOAD_TASK = 2;

// 默认同时写入日志文件数.
static NSInteger DEFAULT_ACTIVE_LOG_WRITER = 2;

// 默认是否删除已上传日志文件.
static BOOL DEFAULT_DELETE_UPLOADED_LOG_FILE = NO;

// 默认是否自动捕捉未捕捉的异常.
static BOOL DEFAULT_CAUGHT_EXCEPTION = NO;

// 默认单个日志文件最大容量（单位：字节）.
static unsigned long long DEFAULT_LOG_FILE_MAX_SIZE = 524288;

// 默认日志系统刷新时间间隔（单位：秒）.
static NSInteger DEFAULT_UPDATE_SYSTEM_FREQUENCY = 3600;

// 默认 http 连接超时（单位：毫秒）.
static NSInteger DEFAULT_HTTP_REQUEST_TIMEOUT = 500;

static BOOL SYSTEM_DEBUG_MODE = YES;

static int FILE_STATE_NORMAL = 0x01;

static int FILE_STATE_WILL_UPLOAD = 0x02;

static int FILE_STATE_UPLOADED = 0x03;

static int FILE_STATE_DELETED = 0x04;

static int DEFAULT_SCREENSHOT_QUALITY = 80;

static float DEFAULT_SCREENSHOT_SCALE = 0.5;

@interface GTLoggerConstants : NSObject

+ (NSString *)logLevelName:(NSInteger)level;

/**
 *  默认记录的日志 level 级别.
 *
 *  @return level array
 */
+ (NSArray *)defaultRecordLogLevels;

/**
 *  默认可以上传日志文件的网络类型.
 *
 *  @return network type array
 */
+ (NSArray *)defaultUploadNetworkType;

@end
