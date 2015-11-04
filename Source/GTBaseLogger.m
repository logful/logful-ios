//
//  BaseLogger.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/6.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTBaseLogger.h"
#import "GTConstants.h"
#import "GTLoggerConstants.h"
#import "GTBaseLogEvent.h"
#import "GTAppenderManager.h"
#import "GTVerifyMsgLayout.h"
#import "GTMsgLayout.h"
#import "GTDatabaseManager.h"
#import "GTStringUtils.h"
#import "GTCaptureTool.h"

@interface GTBaseLogger ()

@property (nonatomic, strong) NSString *layoutString;

@end

@implementation GTBaseLogger

- (void)verbose:(NSString *)tag msg:(NSString *)msg {
    [self logMessage:LEVEL_VERBOSE tag:tag msg:msg capture:NO];
}

- (void)verbose:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    [self logMessage:LEVEL_VERBOSE tag:tag msg:msg capture:capture];
}

- (void)debug:(NSString *)tag msg:(NSString *)msg {
    [self logMessage:LEVEL_DEBUG tag:tag msg:msg capture:NO];
}

- (void)debug:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    [self logMessage:LEVEL_DEBUG tag:tag msg:msg capture:capture];
}

- (void)info:(NSString *)tag msg:(NSString *)msg {
    [self logMessage:LEVEL_INFO tag:tag msg:msg capture:NO];
}

- (void)info:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    [self logMessage:LEVEL_INFO tag:tag msg:msg capture:capture];
}

- (void)warn:(NSString *)tag msg:(NSString *)msg {
    [self logMessage:LEVEL_WARN tag:tag msg:msg capture:NO];
}

- (void)warn:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    [self logMessage:LEVEL_WARN tag:tag msg:msg capture:capture];
}

- (void)error:(NSString *)tag msg:(NSString *)msg {
    [self logMessage:LEVEL_ERROR tag:tag msg:msg capture:NO];
}

- (void)error:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    [self logMessage:LEVEL_ERROR tag:tag msg:msg capture:capture];
}

- (void)exception:(NSString *)tag msg:(NSString *)msg {
    [self logMessage:LEVEL_EXCEPTION tag:tag msg:msg capture:NO];
}

- (void)exception:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    [self logMessage:LEVEL_EXCEPTION tag:tag msg:msg capture:capture];
}

- (void)fatal:(NSString *)tag msg:(NSString *)msg {
    [self logMessage:LEVEL_FATAL tag:tag msg:msg capture:NO];
}

- (void)fatal:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    [self logMessage:LEVEL_FATAL tag:tag msg:msg capture:capture];
}

- (void)setMsgLayout:(NSString *)string {
    // Verify layout template string
    [GTVerifyMsgLayout verify:string];
    _layoutString = string;
}

- (NSString *)getMsgLayout {
    return _layoutString;
}

- (void)logMessage:(int)level tag:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    if (![self isEnabled:level]) {
        return;
    }
    if ([GTStringUtils isEmpty:tag] || [GTStringUtils isEmpty:msg]) {
        return;
    }
    if (capture) {
        [GTCaptureTool captureThenLog:self level:level tag:tag msg:msg];
    } else {
        GTBaseLogEvent *logEvent = [GTBaseLogEvent createEvent:[self getName]
                                                         level:level
                                                           tag:tag
                                                       message:msg
                                                  layoutString:_layoutString];
        [GTAppenderManager append:logEvent];
    }
}

@end
