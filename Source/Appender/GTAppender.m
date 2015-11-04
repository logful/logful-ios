//
//  Appender.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTAppender.h"
#import "GTBaseErrorHandler.h"
#import "GTLayout.h"

@interface GTAppender ()

@property (nonatomic, strong, nonnull) NSString *loggerName;
@property (nonatomic, strong, nonnull) GTLayout *lauout;
@property (nonatomic, assign) BOOL ignoreError;
@property (nonatomic, strong, nonnull) GTErrorHandler *errorHandler;

@end

@implementation GTAppender

- (instancetype)initWithLoggerName:(NSString *)loggerName
                            layout:(GTLayout *)layout
                       ignoreError:(BOOL)ignoreError {
    self = [super init];
    if (self) {
        self.loggerName = loggerName;
        self.lauout = layout;
        self.ignoreError = ignoreError;
        self.errorHandler = [[GTBaseErrorHandler alloc] init];
    }
    return self;
}

- (void)append:(GTLogEvent *)event {
    // Rewrite
}

- (GTErrorHandler *)hander {
    return self.errorHandler;
}

- (GTLayout *)layout {
    return self.lauout;
}

- (NSString *)loggerName {
    return self.loggerName;
}

- (BOOL)ignoreError {
    return self.ignoreError;
}

- (void)setHandler:(GTErrorHandler *)handler {
    if (handler == nil) {
        return;
    }
    self.errorHandler = handler;
}

- (int)fragment {
    // Rewrite
    return 0;
}

- (BOOL)writing {
    // Rewrite
    return NO;
}

- (BOOL)writeable {
    // Rewrite
    return NO;
}

- (void)start {
    // Rewrite
}

- (void)stop {
    // Rewrite
}

- (BOOL)isStarted {
    // Rewrite
    return NO;
}

- (BOOL)isStoped {
    // Rewrite
    return YES;
}

@end
