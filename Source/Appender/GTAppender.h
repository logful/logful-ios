//
//  Appender.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLogEvent;
@class GTErrorHandler;
@class GTLayout;

@interface GTAppender : NSObject

- (instancetype)initWithLoggerName:(NSString *)loggerName
                            layout:(GTLayout *)layout
                       ignoreError:(BOOL)ignoreError;

- (void)append:(GTLogEvent *)event;
- (GTErrorHandler *)hander;
- (GTLayout *)layout;
- (NSString *)loggerName;
- (BOOL)ignoreError;
- (void)setHandler:(GTErrorHandler *)handler;
- (int)fragment;
- (BOOL)writing;
- (BOOL)writeable;

// Life cycle
- (void)start;
- (void)stop;
- (BOOL)isStarted;
- (BOOL)isStoped;

@end
