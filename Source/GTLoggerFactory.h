//
//  LoggerFactory.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLogger.h"
#import "GTLoggerConfigurator.h"
#import <Foundation/Foundation.h>

/**
 * 日志系统入口文件.
 */
@interface GTLoggerFactory : NSObject

/**
 *  使用默认参数进行初始化.
 */
+ (void)init;

/**
 *  使用自定义配置进行初始化.
 *
 *  @param config 初始化参数配置
 */
+ (void)initWithConfig:(GTLoggerConfigurator *)config;

/**
 *  获取当前参数配置.
 *
 *  @return 参数配置
 */
+ (GTLoggerConfigurator *)config;

/**
 *  Get current log library version.
 *
 *  @return Version string
 */
+ (NSString *)version;

/**
 *  Get logger.
 *
 *  @param loggerName Logger name
 *
 *  @return Logger instance
 */
+ (GTLogger *)logger:(NSString *)loggerName;

/**
 *  Set app key.
 *
 *  @param key App key string
 */
+ (void)setAppKey:(NSString *)key;

/**
 *  Set app secret.
 *
 *  @param secret App secret string
 */
+ (void)setAppSecret:(NSString *)secret;

/**
 *  set logful api address.
 *
 *  @param logful api address.
 */
+ (void)setApiUrl:(NSString *)url;

/**
 *  Bind log system alias.
 *
 *  @param alias Alias name
 */
+ (void)bindAlias:(NSString *)alias;

/**
 *  Turn on log system.
 */
+ (void)turnOn;

/**
 *  Turn off log system.
 */
+ (void)turnOff;

/**
 *  Get log system status.
 *
 *  @return System status
 */
+ (BOOL)isOn;

/**
 *  Sync all log file.
 */
+ (void)sync;

/**
 *  Sync log file create time in [startTime, endTime].
 *
 *  @param startTime Start time
 *  @param endTime   End time
 */
+ (void)sync:(uint64_t)startTime endTime:(uint64_t)endTime;

/**
 *  Interrupt all writting log file and sync.
 */
+ (void)interruptThenSync;

/**
 *  使用默认的 logger 打印 verbose 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_VERBOSE(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印带有截图的 verbose 日志
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_VERBOSE_CAPTURE(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印 debug 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_DEBUG(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印带有截图的 debug 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_DEBUG_CAPTURE(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印 info 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_INFO(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印带有截图的 info 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_INFO_CAPTURE(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印 warn 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_WARN(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印带有截图的 warn 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_WARN_CAPTURE(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印 error 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_ERROR(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印带有截图的 error 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_ERROR_CAPTURE(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印 exception 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_EXCEPTION(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印带有截图的 exception 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_EXCEPTION_CAPTURE(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印 fatal 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_FATAL(NSString *tag, NSString *msg);

/**
 *  使用默认的 logger 打印带有截图的 fatal 日志.
 *
 *  @param tag Tag
 *  @param msg Message
 */
void GLOG_FATAL_CAPTURE(NSString *tag, NSString *msg);

@end
