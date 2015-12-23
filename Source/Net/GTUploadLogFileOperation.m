//
//  GTUploadLogFileOperation.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTChecksum.h"
#import "GTCryptoTool.h"
#import "GTDatabaseManager.h"
#import "GTDateTimeUtil.h"
#import "GTDeviceID.h"
#import "GTGzipTool.h"
#import "GTLogFileMeta.h"
#import "GTLogStorage.h"
#import "GTLoggerConfigurator.h"
#import "GTLoggerConstants.h"
#import "GTLoggerFactory.h"
#import "GTMultipartInputStream.h"
#import "GTStringUtils.h"
#import "GTSystemConfig.h"
#import "GTUploadLogFileOperation.h"

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

    NSDictionary *dic1 = @{
        @"platform" : @(PLATFORM_IOS),
        @"uid" : [GTDeviceID uid],
        @"appId" : [[NSBundle mainBundle] bundleIdentifier],
        @"loggerName" : self.meta.loggerName,
        @"layouts" : self.layoutJson,
        @"level" : [NSString stringWithFormat:@"%d", self.meta.level],
        @"fileSum" : fileMD5,
        @"alias" : [GTSystemConfig alias]
    };
    NSString *attr = [GTStringUtils convertToString:dic1];
    if (!attr) {
        return nil;
    }
    NSData *chunk = [GTCryptoTool encryptAES:[attr dataUsingEncoding:NSUTF8StringEncoding]];
    if (!chunk) {
        return nil;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[GTLoggerFactory version] forKey:@"sdkVersion"];
    [dictionary setObject:[GTCryptoTool securityString] forKey:@"signature"];
    [dictionary setObject:[chunk base64EncodedStringWithOptions:0] forKey:@"chunk"];
    NSString *payload = [GTStringUtils convertToString:dictionary];
    if (!payload) {
        return nil;
    }

    GTMultipartInputStream *body = [[GTMultipartInputStream alloc] init];
    [body addPartWithName:@"payload" string:payload];
    [body addPartWithName:@"logFile" path:outFilePath];
    return body;
}

- (NSURL *)url {
    return [GTSystemConfig apiUrl:UPLOAD_LOG_FILE_URI];
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
