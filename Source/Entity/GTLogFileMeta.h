//
//  LogFileMeta.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLogFileMeta;
@class GTLogEvent;

@interface GTLogFileMeta : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, copy, nonnull) NSString *loggerName;
@property (nonatomic, copy, nonnull) NSString *filename;
@property (nonatomic, assign) int fragment;
@property (nonatomic, assign) int status;
@property (nonatomic, copy, nullable) NSString *fileMD5;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int64_t createTime;
@property (nonatomic, assign) int64_t deleteTime;
@property (nonatomic, copy, nullable) NSString *date;
@property (nonatomic, assign) BOOL eof;

+ (GTLogFileMeta *__nonnull)create:(GTLogEvent *__nonnull)logEvent
                          filename:(NSString *__nonnull)fileName
                          fragment:(int)fragment;


@end
