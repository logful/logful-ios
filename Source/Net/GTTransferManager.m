//
//  TransferManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/1.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTTransferManager.h"
#import "GTReachabilityManager.h"
#import "GTLogFileMeta.h"
#import "GTLoggerFactory.h"
#import "GTMsgLayout.h"
#import "GTDatabaseManager.h"
#import "GTUploadLogFileOperation.h"
#import "GTUploadCrashReportOperation.h"
#import "GTUploadSystemInfoOperation.h"
#import "GTLoggerConstants.h"
#import "GTAttachmentFileMeta.h"
#import "GTUploadAttachmentFileOperation.h"

@interface GTTransferManager ()

@property (nonatomic, strong, nonnull) NSOperationQueue *transferQueue;

@end

@implementation GTTransferManager

+ (id)manager {
    static GTTransferManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)uploadSystemInfo {
    if (![GTReachabilityManager shouldUpload]) {
        return;
    }

    GTTransferManager *manager = [GTTransferManager manager];
    GTUploadSystemInfoOperation *operation = [[GTUploadSystemInfoOperation alloc] init];
    [manager addOperation:operation];
}

+ (void)uploadLogFile {
    if (![GTReachabilityManager shouldUpload]) {
        return;
    }

    GTTransferManager *manager = [GTTransferManager manager];

    // Upload log file.
    GTLoggerConfigurator *config = [GTLoggerFactory config];
    if (config != nil) {
        NSArray *metaList = [[GTDatabaseManager manager] findLogFileMetaListByLevel:config.uploadLogLevel];
        [manager uploadLogFile:metaList];
    }
}

+ (void)uploadLogFile:(uint64_t)startTime endTime:(uint64_t)endTime {
    if (![GTReachabilityManager shouldUpload]) {
        return;
    }

    GTTransferManager *manager = [GTTransferManager manager];
    GTLoggerConfigurator *config = [GTLoggerFactory config];
    if (config != nil) {
        NSArray *metaList = [[GTDatabaseManager manager] findLogFileMetaListByLevelAndTime:config.uploadLogLevel
                                                                                 startTime:startTime
                                                                                   endTime:endTime];
        [manager uploadLogFile:metaList];
    }
}

+ (void)uploadCrashReport {
    if (![GTReachabilityManager shouldUpload]) {
        return;
    }

    //GTTransferManager *manager = [GTTransferManager manager];
    // TODO
}

+ (void)uploadAttachment {
    if (![GTReachabilityManager shouldUpload]) {
        return;
    }

    GTTransferManager *manager = [GTTransferManager manager];
    NSArray *metaList = [[GTDatabaseManager manager] findAllNotUploadAttachmentMeta];
    for (GTAttachmentFileMeta *meta in metaList) {
        GTUploadAttachmentFileOperation *operation = [GTUploadAttachmentFileOperation create:meta];
        [manager addOperation:operation];
    }
}

- (NSOperationQueue *)getTransferQueue {
    if (_transferQueue == nil) {
        _transferQueue = [[NSOperationQueue alloc] init];
        GTLoggerConfigurator *config = [GTLoggerFactory config];
        if (config != nil) {
            _transferQueue.maxConcurrentOperationCount = config.activeUploadTask;
        } else {
            _transferQueue.maxConcurrentOperationCount = DEFAULT_ACTIVE_UPLOAD_TASK;
        }
    }
    return _transferQueue;
}

- (void)uploadLogFile:(NSArray *)metaList {
    if (metaList.count == 0) {
        return;
    }

    NSString *layoutJson = [[GTDatabaseManager manager] layoutJsonArray];
    for (GTLogFileMeta *meta in metaList) {
        if (meta.eof && meta.status == FILE_STATE_WILL_UPLOAD) {
            GTUploadLogFileOperation *operation = [GTUploadLogFileOperation create:meta];
            [operation setMsgLayoutParam:layoutJson];
            [self addOperation:operation];
        }
    }
}

- (void)addOperation:(GTUploadOperation *)operation {
    NSString *identifier = [operation identifier];
    NSArray *operations = _transferQueue.operations;
    BOOL exists = NO;
    for (GTUploadOperation *operation in operations) {
        if ([[operation identifier] isEqualToString:identifier]) {
            exists = YES;
            break;
        }
    }

    if (!exists) {
        [[self getTransferQueue] addOperation:operation];
    }
}

@end
