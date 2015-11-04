//
//  CrashReportFileMeta.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/25.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTCrashReportFileMeta.h"
#import "GTDateTimeUtil.h"
#import "GTLoggerConstants.h"

@implementation GTCrashReportFileMeta

- (instancetype)init {
    self = [super init];
    if (self) {
        self.id = -1;
        self.status = FILE_STATE_NORMAL;
        self.createTime = [GTDateTimeUtil currentTimeMillis];
    }
    return self;
}

+ (GTCrashReportFileMeta *)create:(NSString *)filename {
    GTCrashReportFileMeta *meta = [[GTCrashReportFileMeta alloc] init];
    meta.filename = filename;
    return meta;
}

@end
