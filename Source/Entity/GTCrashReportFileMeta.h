//
//  CrashReportFileMeta.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/25.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTCrashReportFileMeta : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, copy, nonnull) NSString *filename;
@property (nonatomic, assign) int64_t createTime;
@property (nonatomic, assign) int64_t deleteTime;
@property (nonatomic, assign) int status;
@property (nonatomic, copy, nonnull) NSString *fileMD5;

+ (GTCrashReportFileMeta *__nonnull)create:(NSString *__nonnull)filename;

@end
