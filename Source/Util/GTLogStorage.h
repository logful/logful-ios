//
//  GTLogStorage.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLogStorage : NSObject

+ (void)initStorage;
+ (BOOL)fileExistsAtPath:(NSString *)filePath;

+ (NSString *)logDir;
+ (NSString *)crashReportDir;
+ (NSString *)cacheDir;

+ (NSString *)logFilePath:(NSString *)filename;
+ (NSString *)attachmentFilePath:(NSString *)filename;
+ (NSString *)cacheFilePath:(NSString *)filename;

+ (BOOL)isLogFile:(NSString *)filename;
+ (unsigned long long)logFileSize:(NSString *)filename;

+ (NSString *)systemInfoFilePath;
+ (NSString *)systemConfigFilePath;

@end
