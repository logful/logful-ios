//
//  GTFileReportSender.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/8.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTFileReportSender.h"
#import "GTLogStorage.h"
#import "GTLoggerConstants.h"
#import "GTDateTimeUtil.h"

@interface GTFileReportSender ()

@property (nonatomic, strong) NSFileHandle *fileHandle;

@end

@implementation GTFileReportSender

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createFileHandle];
    }
    return self;
}

- (void)createFileHandle {
    NSString *crashReportDir = [GTLogStorage crashReportDir];
    NSString *filename = [self generateCrashReportFilename];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", crashReportDir, filename];

    NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (handler == nil) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        handler = [NSFileHandle fileHandleForWritingAtPath:filePath];
    }

    self.fileHandle = handler;
}

- (void)send:(GTCrashReportData *)reportData {
    // TODO
}

- (NSString *)generateCrashReportFilename {
    return [NSString stringWithFormat:@"%@-%lld.bin",
                                      CRASH_REPORT_FILE_PREFIX,
                                      [GTDateTimeUtil currentTimeMillis]];
}

- (void)trySendCrashReportFile {
    // TODO
}

@end
