//
//  LoggerConfigurator.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTSecurityProvider.h"
#import <Foundation/Foundation.h>

@class ConfiguratorBuilder;

@interface GTLoggerConfigurator : NSObject

- (unsigned long long)logFileMaxSize;
- (NSArray *__nonnull)uploadNetworkType;
- (NSArray *__nonnull)uploadLogLevel;
- (BOOL)deleteUploadedLogFile;
- (int64_t)updateSystemFrequency;
- (NSInteger)activeUploadTask;
- (NSInteger)activeLogWriter;
- (BOOL)caughtException;
- (NSString *__nonnull)defaultLoggerName;
- (NSString *__nonnull)defaultMsgLayout;
- (int)screenshotQuality;
- (float)screenshotScale;
- (id<GTSecurityProvider> __nonnull)securityProvider;

/**
 *  Build config with block.
 *
 *  @param builderBlock Build block
 *
 *  @return GTLoggerConfigurator instance
 */
+ (instancetype __nonnull)configWithBlock:(void (^__nonnull)(ConfiguratorBuilder *__nonnull))builderBlock;

@end

@interface ConfiguratorBuilder : NSObject

@property (nonatomic, assign) unsigned long long logFileMaxSize;

/**
 * 允许上传日志文件的网络环境.
 */
@property (nonatomic, strong, nonnull) NSArray *uploadNetworkType;

/**
 * 需要上传的日志级别.
 */
@property (nonatomic, strong, nonnull) NSArray *uploadLogLevel;

/**
 * 是否删除已经上传的日志文件.
 */
@property (nonatomic, assign) BOOL deleteUploadedLogFile;

/**
 * 定时刷新日志系统（单位：秒）.
 */
@property (nonatomic, assign) int64_t updateSystemFrequency;

/**
 * 同时上传文件数量.
 */
@property (nonatomic, assign) NSInteger activeUploadTask;

/**
 * 同时写入日志文件数量.
 */
@property (nonatomic, assign) NSInteger activeLogWriter;

/**
 * 是否捕捉未捕捉的异常信息.
 */
@property (nonatomic, assign) BOOL caughtException;

/**
 *  默认的 logger 名称.
 */
@property (nonatomic, strong, nonnull) NSString *defaultLoggerName;

/**
 *  默认的消息模板.
 */
@property (nonatomic, strong, nonnull) NSString *defaultMsgLayout;

/**
 *  截图文件压缩质量（1 ~ 100）.
 */
@property (nonatomic, assign) int screenshotQuality;

/**
 *  截图文件缩放比例（0.1 ~ 1）.
 */
@property (nonatomic, assign) float screenshotScale;

@property (nonatomic, strong, nonnull) id<GTSecurityProvider> securityProvider;

- (GTLoggerConfigurator *__nonnull)build;

@end
