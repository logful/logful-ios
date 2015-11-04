//
//  LogFileMeta.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLogFileMeta.h"
#import "GTLogEvent.h"
#import "GTDateTimeUtil.h"
#import "GTLoggerConstants.h"

@implementation GTLogFileMeta

- (instancetype)init {
    self = [super init];
    if (self) {
        self.id = -1;
        self.status = FILE_STATE_NORMAL;
        self.createTime = [GTDateTimeUtil currentTimeMillis];
        self.date = [GTDateTimeUtil dateString];
        self.eof = NO;
    }
    return self;
}

+ (GTLogFileMeta *__nonnull)create:(GTLogEvent *__nonnull)logEvent
                          filename:(NSString *__nonnull)fileName
                          fragment:(int)fragment {
    GTLogFileMeta *meta = [[GTLogFileMeta alloc] init];
    meta.loggerName = [logEvent getLoggerName];
    meta.level = [logEvent getLevel];
    meta.filename = fileName;
    meta.fragment = fragment;
    return meta;
}

@end
