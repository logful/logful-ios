//
//  GTDBManager.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/7.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLogFileMeta;
@class GTCrashReportFileMeta;
@class GTMsgLayout;
@class GTAttachmentFileMeta;

@class GTLogEvent;

@interface GTDatabaseManager : NSObject

+ (nonnull instancetype)manager;

- (BOOL)saveLogFileMeta:(GTLogFileMeta *__nonnull)meta;
- (BOOL)saveCrashReportFileMeta:(GTCrashReportFileMeta *__nonnull)meta;
- (int16_t)saveMsgLayout:(GTMsgLayout *__nonnull)layout;
- (BOOL)saveAttachmentFileMeta:(GTAttachmentFileMeta *__nonnull)meta;

/**
 *  Find max attachment sequence int number. <br/>
 *  <br/>
 *  Return -1 when no record exist.
 *
 *  @return Sequence number
 */
- (int32_t)findMaxAttachmentSequence;

- (int16_t)layoutId:(NSString *__nonnull)layoutString;

- (BOOL)closeLogFile:(NSString *__nonnull)loggerName level:(int)level fragment:(int)fragment;

/**
 *  关闭所有正在写入的日志文件.
 *
 *  @return result
 */
- (BOOL)closeAllLogFile;

/**
 *  查找日志文件记录最大计数.
 *
 *  @param logEvent Log event
 *
 *  @return Log file meta
 */
- (GTLogFileMeta *__nullable)findMaxFragment:(GTLogEvent *__nonnull)logEvent;

/**
 *  查找所有的日志文件记录.
 *
 *  @return Log file meta list
 */
- (NSArray *__nonnull)findAllLogFileMetaList;

/**
 *  查找所有未上传的日志文件记录.
 *
 *  @return Log file meta list
 */
- (NSArray *__nonnull)findAllNotUploadLogFileMetaList;

/**
 *  查找指定 level 的日志文件记录.
 *
 *  @param levels Level array
 *
 *  @return Log file meta list
 */
- (NSArray *__nonnull)findLogFileMetaListByLevel:(NSArray *__nonnull)levels;

/**
 *  查找指定 level 未上传的日志文件记录.
 *
 *  @return Log file meta list
 */
- (NSArray *__nonnull)findAllNotUploadLogFileMetaListByLevel:(NSArray *__nonnull)levels;

/**
 *  查找指定时间间隔内创建的日志文件记录.
 *
 *  @param startTime Start time
 *  @param endTime   End time
 *
 *  @return Log file meta list
 */
- (NSArray *__nonnull)findLogFileMetaListByTime:(int64_t)startTime endTime:(int64_t)endTime;


/**
 *  查找指定 level 和时间间隔内创建的日志文件记录.
 *
 *  @param levels    Levels array
 *  @param startTime Start time
 *  @param endTime   End time
 *
 *  @return Log file meta list
 */
- (NSArray *__nonnull)findLogFileMetaListByLevelAndTime:(NSArray *__nonnull)levels
                                              startTime:(int64_t)startTime
                                                endTime:(int64_t)endTime;

/**
 *  查找指定 level 和时间间隔内未上传的日志文件记录.
 *
 *  @param levels    Levels array
 *  @param startTime Start time
 *  @param endTime   End time
 *
 *  @return Log file meta list
 */
- (NSArray *__nonnull)findAllNotUploadLogFileMetaListByLevelAndTime:(NSArray *__nonnull)levels
                                                          startTime:(int64_t)startTime
                                                            endTime:(int64_t)endTime;

/**
 *  查找所有未上传成功的崩溃日志文件.
 *
 *  @return Crash report file meta list
 */
- (NSArray *__nonnull)findAllNotUploadCrashReportMeta;

- (NSString *__nonnull)layoutJsonArray;

/**
 *  查找所有未上传的附件文件记录.
 *
 *  @return attachment file meta list
 */
- (NSArray *__nonnull)findAllNotUploadAttachmentMeta;

- (BOOL)deleteElement:(NSObject *__nonnull)element;

@end
