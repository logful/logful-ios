//
//  GTUploadLogFileOperation.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTUploadLogFileOperation.h"
#import "GTLogFileMeta.h"
#import "GTLogStorage.h"
#import "GTGzipTool.h"
#import "GTChecksum.h"
#import "GTLoggerConstants.h"
#import "GTMultipartInputStream.h"
#import "GTDeviceID.h"
#import "GTDatabaseManager.h"
#import "GTLoggerConfigurator.h"
#import "GTLoggerFactory.h"
#import "GTDateTimeUtil.h"
#import "GTSystemConfig.h"

@interface GTUploadLogFileOperation ()

@property (nonatomic, strong) GTLogFileMeta *meta;
@property (nonatomic, strong) NSString *layoutJson;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation GTUploadLogFileOperation

+ (instancetype)create:(GTLogFileMeta *)meta {
    return [[self alloc] initWithLogFileMeta:meta];
}

- (instancetype)initWithLogFileMeta:(GTLogFileMeta *)meta {
    self = [super init];
    if (self) {
        self.meta = meta;
    }
    return self;
}

- (void)setMsgLayoutParam:(NSString *)layoutJson {
    self.layoutJson = layoutJson;
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"%lld-%d", self.meta.id, 1];
}

- (GTMultipartInputStream *)bodyStream {
    if (_meta == nil) {
        return nil;
    }

    if (_layoutJson == nil || _layoutJson.length == 0) {
        return nil;
    }

    NSString *inFilePath = [GTLogStorage logFilePath:_meta.filename];

    // Check exist and is file.
    if (![GTLogStorage fileExistsAtPath:inFilePath]) {
        return nil;
    }

    NSString *outFilePath = [GTLogStorage cacheFilePath:_meta.filename];

    // Compress log file.
    NSError *error;
    if (![GTGzipTool compress:inFilePath outFilePath:outFilePath error:&error]) {
        return nil;
    }

    // Calculate out gzip file md5.
    NSString *fileMD5 = [GTChecksum fileMD5:outFilePath];
    if (fileMD5 == nil) {
        return nil;
    }

    self.filePath = inFilePath;

    GTMultipartInputStream *body = [[GTMultipartInputStream alloc] init];
    [body addPartWithName:@"platform" string:@"ios"];
    [body addPartWithName:@"sdkVersion" string:[GTLoggerFactory version]];
    [body addPartWithName:@"uid" string:[GTDeviceID uid]];
    [body addPartWithName:@"appId" string:[[NSBundle mainBundle] bundleIdentifier]];
    [body addPartWithName:@"loggerName" string:self.meta.loggerName];
    [body addPartWithName:@"layouts" string:self.layoutJson];
    [body addPartWithName:@"level" string:[NSString stringWithFormat:@"%d", self.meta.level]];
    [body addPartWithName:@"fileSum" string:fileMD5];
    [body addPartWithName:@"alias" string:[GTSystemConfig alias]];
    [body addPartWithName:@"logFile" path:outFilePath];

    return body;
}

- (NSURL *)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                           [GTSystemConfig baseUrl],
                                                           UPLOAD_LOG_FILE_URI]];
}

- (void)success {
    // Change log file meta status.
    GTLoggerConfigurator *config = [GTLoggerFactory config];
    if (config != nil && [config deleteUploadedLogFile]) {
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:_filePath error:&error];
        if (result && !error) {
            _meta.status = FILE_STATE_DELETED;
            _meta.deleteTime = [GTDateTimeUtil currentTimeMillis];
            [[GTDatabaseManager manager] saveLogFileMeta:_meta];
        } else {
            _meta.status = FILE_STATE_UPLOADED;
            [[GTDatabaseManager manager] saveLogFileMeta:_meta];
        }
    } else {
        _meta.status = FILE_STATE_UPLOADED;
        [[GTDatabaseManager manager] saveLogFileMeta:_meta];
    }
}

- (void)failure {
    if (SYSTEM_DEBUG_MODE) {
    }
}

@end
