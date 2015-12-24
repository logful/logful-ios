//
//  GTLogStorage.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLogStorage.h"
#import "GTLoggerConstants.h"

@interface GTLogStorage ()

@property (nonatomic, strong) NSString *logDirPath;
@property (nonatomic, strong) NSString *crashReportDirPath;
@property (nonatomic, strong) NSString *attachmentDirPath;
@property (nonatomic, strong) NSString *cacheDirPath;

@end

@implementation GTLogStorage

+ (id)storage {
    static GTLogStorage *storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[self alloc] init];
    });
    return storage;
}

+ (void)initStorage {
    GTLogStorage *storage = [GTLogStorage storage];
    if (storage.logDirPath == nil) {
        storage.logDirPath = [storage dirWithName:LOG_DIR_NAME];
    }
    if (storage.crashReportDirPath == nil) {
        storage.crashReportDirPath = [storage dirWithName:CRASH_REPORT_DIR_NAME];
    }
    if (storage.attachmentDirPath == nil) {
        storage.attachmentDirPath = [storage dirWithName:ATTACHMENT_DIR_NAME];
    }
    if (storage.cacheDirPath == nil) {
        storage.cacheDirPath = [storage dirWithName:CACHE_DIR_NAME];
    }
}

+ (BOOL)fileExistsAtPath:(NSString *)filePath {
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    if (exists && !isDir) {
        return YES;
    }
    return NO;
}

+ (NSString *)logDir {
    GTLogStorage *storage = [GTLogStorage storage];
    return storage.logDirPath;
}

+ (NSString *)crashReportDir {
    GTLogStorage *storage = [GTLogStorage storage];
    return storage.crashReportDirPath;
}

+ (NSString *)cacheDir {
    GTLogStorage *storage = [GTLogStorage storage];
    return storage.cacheDirPath;
}

+ (NSString *)logFilePath:(NSString *)filename {
    GTLogStorage *storage = [GTLogStorage storage];
    return [NSString stringWithFormat:@"%@/%@", storage.logDirPath, filename];
}

+ (NSString *)attachmentFilePath:(NSString *)filename {
    GTLogStorage *storage = [GTLogStorage storage];
    return [NSString stringWithFormat:@"%@/%@", storage.attachmentDirPath, filename];
}

+ (NSString *)cacheFilePath:(NSString *)filename {
    GTLogStorage *storage = [GTLogStorage storage];
    return [NSString stringWithFormat:@"%@/%@", storage.cacheDirPath, filename];
}

+ (BOOL)isLogFile:(NSString *)filename {
    NSString *filePath = [self logFilePath:filename];
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    return exists && !isDir;
}

+ (unsigned long long)logFileSize:(NSString *)filename {
    NSString *filePath = [self logFilePath:filename];
    NSError *error;
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath
                                                                                error:&error];
    if (!error) {
        return [dictionary fileSize];
    }
    return 0;
}

+ (NSString *)systemConfigFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:LOG_SYSTEM_DIR_NAME];
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if (exists && isDir) {
        NSString *path = [NSString stringWithFormat:@"/%@/%@", LOG_SYSTEM_DIR_NAME, SYSTEM_CONFIG_FILE_NAME];
        return [documentsDirectory stringByAppendingPathComponent:path];
    }

    return nil;
}

- (NSString *)dirWithName:(NSString *)dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"/%@/%@", LOG_SYSTEM_DIR_NAME, dirName];
    NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:path];

    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];

    if (exists && isDir) {
        return dirPath;
    } else if (exists && !isDir) {
        // Dir path exist but is a file.
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:dirPath error:&error];
        if (!error) {
            error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:&error];
            if (!error) {
                return dirPath;
            } else {
                [NSException raise:@"CreateDirFailedException" format:@"Create dir failed."];
            }
        } else {
            [NSException raise:@"DeleteDirFailedException" format:@"Delete dir failed."];
        }
    } else {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (!error) {
            return dirPath;
        } else {
            [NSException raise:@"CreateDirFailedException" format:@"Create dir failed."];
        }
    }

    return nil;
}

@end
