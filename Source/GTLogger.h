//
//  Logger.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/6.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 * 用于打印日志的 Logger. 
 */
@interface GTLogger : NSObject

/**
 *  初始化 logger.
 *
 *  @param loggerName Logger 名称
 *
 *  @return Logger 实例
 */
- (id)initWithName:(NSString *)loggerName;

/**
 *  获取当前 logger 名称.
 *
 *  @return Logger name
 */
- (NSString *)getName;

/**
 *  获取当前设置的消息模板.
 *
 *  @return 消息模板
 */
- (NSString *)getMsgLayout;

/**
 *  指定 level 是否允许打印日志.
 *
 *  @param level Log level
 *
 *  @return 是否允许
 */
- (BOOL)isEnabled:(int)level;

/**
 *  设置当前 logger 需要打印的日志级别.
 *
 *  @param levels 日志级别
 */
- (void)recordLogLevel:(NSArray *)levels;

/**
 *  打印 verbose 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 */
- (void)verbose:(NSString *)tag msg:(NSString *)msg;

/**
 *  打印 verbose 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 *  @param capture Capture
 */
- (void)verbose:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture;

/**
 *  打印 debug 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 */
- (void)debug:(NSString *)tag msg:(NSString *)msg;

/**
 *  打印 debug 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 *  @param capture Capture
 */
- (void)debug:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture;

/**
 *  打印 info 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 */
- (void)info:(NSString *)tag msg:(NSString *)msg;

/**
 *  打印 info 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 *  @param capture Capture
 */
- (void)info:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture;

/**
 *  打印 warn 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 */
- (void)warn:(NSString *)tag msg:(NSString *)msg;

/**
 *  打印 warn 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 *  @param capture Capture
 */
- (void)warn:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture;

/**
 *  打印 error 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 */
- (void)error:(NSString *)tag msg:(NSString *)msg;

/**
 *  打印 error 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 *  @param capture Capture
 */
- (void)error:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture;

/**
 *  打印 exception 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 */
- (void)exception:(NSString *)tag msg:(NSString *)msg;

/**
 *  打印 exception 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 *  @param capture Capture
 */
- (void)exception:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture;

/**
 *  打印 fatal 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 */
- (void)fatal:(NSString *)tag msg:(NSString *)msg;

/**
 *  打印 fatal 信息.
 *
 *  @param tag Tag
 *  @param msg Message
 *  @param capture Capture
 */
- (void)fatal:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture;

/**
 *  设置当前 logger 消息模板.
 *
 *  @param string 模板内容
 */
- (void)setMsgLayout:(NSString *)string;

@end
