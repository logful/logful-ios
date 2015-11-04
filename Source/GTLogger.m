//
//  Logger.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/6.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLogger.h"
#import "GTLoggerConstants.h"

@interface GTLogger ()

@property (nonatomic, strong, nonnull) NSString *loggerName;
@property (nonatomic, strong, nonnull) NSArray *logLevels;

@end

@implementation GTLogger


- (id)initWithName:(NSString *)loggerName {
    if (self = [super init]) {
        self.loggerName = loggerName;
        self.logLevels = [GTLoggerConstants defaultRecordLogLevels];
    }
    return self;
}

- (NSString *)getName {
    return _loggerName;
}

- (NSString *)getMsgLayout {
    return @"";
}

- (BOOL)isEnabled:(int)level {
    for (NSNumber *levelNumber in _logLevels) {
        if ([levelNumber intValue] == level) {
            return YES;
        }
    }
    return NO;
}

- (void)recordLogLevel:(NSArray *)levels {
    if (levels != nil) {
        _logLevels = [NSArray arrayWithArray:levels];
    }
}

- (void)verbose:(NSString *)tag msg:(NSString *)msg {
    // Rewrite
}

- (void)verbose:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    // Rewrite
}

- (void)debug:(NSString *)tag msg:(NSString *)msg {
    // Rewrite
}

- (void)debug:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    // Rewrite
}

- (void)info:(NSString *)tag msg:(NSString *)msg {
    // Rewrite
}

- (void)info:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    // Rewrite
}

- (void)warn:(NSString *)tag msg:(NSString *)msg {
    // Rewrite
}

- (void)warn:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    // Rewrite
}

- (void)error:(NSString *)tag msg:(NSString *)msg {
    // Rewrite
}

- (void)error:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    // Rewrite
}

- (void)exception:(NSString *)tag msg:(NSString *)msg {
    // Rewrite
}

- (void)exception:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    // Rewrite
}

- (void)fatal:(NSString *)tag msg:(NSString *)msg {
    // Rewrite
}

- (void)fatal:(NSString *)tag msg:(NSString *)msg capture:(BOOL)capture {
    // Rewrite
}

- (void)setMsgLayout:(NSString *)string {
    // Rewrite
}

@end
