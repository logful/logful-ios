//
//  GTRefreshScheduleTask.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTRefreshScheduleTask.h"
#import "GTLogFileMeta.h"
#import "GTDateTimeUtil.h"
#import "GTDatabaseManager.h"
#import "GTLoggerConstants.h"

@implementation GTRefreshScheduleTask

- (void)execute {
    // TODO test
    int64_t dayStartTimestamp = [GTDateTimeUtil dayStartTimestamp];
    NSArray *metaList = [[GTDatabaseManager manager] findAllLogFileMetaList];
    for (GTLogFileMeta *meta in metaList) {
        // Close log file except current day.
        if (!meta.eof && meta.status == FILE_STATE_NORMAL) {
            if (meta.createTime < dayStartTimestamp) {
                [meta setEof:YES];
                [meta setStatus:FILE_STATE_WILL_UPLOAD];
                [[GTDatabaseManager manager] saveLogFileMeta:meta];
            }
        }
    }
}

@end
