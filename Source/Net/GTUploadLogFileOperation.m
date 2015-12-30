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
#import "GTLogUtil.h"
#import "GTLogUtil.h"
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
        [GTLogUtil e:NSStringFromClass(self.class) msg:@"Compress log file failed!"];
        return nil;
    }

    // Calculate out gzip file md5.
    NSString *fileMD5 = [GTChecksum fileMD5:outFilePath];
    if (fileMD5 == nil) {
        [GTLogUtil e:NSStringFromClass(self.class) msg:@"Calculate log file md5 failed!"];
        return nil;
    }

    self.filePath = inFilePath;

    NSDictionary *dic1 = @{
        @"platform" : @(PLATFORM_IOS),
        @"uid" : [GTDeviceID uid],
        @"appId" : [[NSBundle mainBundle] bundleIdentifier],
        @"loggerName" : self.meta.loggerName,
        @"layouts" : self.layoutJson,
        @"level" : @(self.meta.level),
        @"fileSum" : fileMD5,
        @"alias" : [GTSystemConfig alias]
    };
    NSString *attr = [GTStringUtils convertToString:dic1];
    if (!attr) {
        return nil;
    }
    NSData *chunk = [GTCryptoTool encryptAES:[attr dataUsingEncoding:NSUTF8StringEncoding]];
    if (!chunk) {
        [GTLogUtil e:NSStringFromClass(self.class) msg:@"Encrypt log file meta data failed!"];
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

    [GTLogUtil i:NSStringFromClass(self.class) msg:[NSString stringWithFormat:@"Will upload log file %@!", _meta.filename]];

    return body;
}

- (NSURL *)url {
    return [GTSystemConfig apiUrl:UPLOAD_LOG_FILE_URI];
}

- (void)success {
    [GTLogUtil i:NSStringFromClass(self.class) msg:[NSString stringWithFormat:@"Upload log file %@ successful!", _meta.filename]];
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
    [GTLogUtil e:NSStringFromClass(self.class) msg:[NSString stringWithFormat:@"Upload log file %@ failed!", _meta.filename]];
}

@end
