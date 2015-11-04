//
//  GTUploadCrashReportOperation.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTUploadCrashReportOperation.h"
#import "GTLoggerConstants.h"
#import "GTCrashReportFileMeta.h"
#import "GTSystemConfig.h"

@interface GTUploadCrashReportOperation ()

@property (nonatomic, strong) GTCrashReportFileMeta *meta;

@end

@implementation GTUploadCrashReportOperation

- (NSString *)identifier {
    return [NSString stringWithFormat:@"%lld-%d", self.meta.id, 2];
}

- (NSURL *)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                           [GTSystemConfig baseUrl],
                                                           UPLOAD_CRASH_REPORT_FILE_URI]];
}

@end
