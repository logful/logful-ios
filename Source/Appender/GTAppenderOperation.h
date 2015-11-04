//
//  GTAppenderOperation.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GTAppender;
@class GTLogEvent;

@interface GTAppenderOperation : NSOperation

/**
 *  Init operation with log file appender and log event.
 *
 *  @param appender Log file appender
 *  @param event    Log evnet
 *
 *  @return Instance of operation
 */
- (instancetype)initWithEvent:(GTLogEvent *)event;

/**
 *  Pauses the execution of the request operation.
 */
- (void)pause;

/**
 *  Whether the request operation is currently paused.
 *
 *  @return `YES` if the operation is currently paused, otherwise `NO`.
 */
- (BOOL)isPaused;

/**
 *  Resumes the execution of the paused request operation.
 */
- (void)resume;

@end
