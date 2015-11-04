//
//  AsyncAppenderManager.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTAppender;
@class GTLogEvent;

@interface GTAppenderManager : NSObject

+ (void)interrupt;

/**
 *  Append log event.
 *
 *  @param event Log event
 */
+ (void)append:(GTLogEvent *)event;

/**
 *  Read lru cache.
 */
+ (void)readCache;

/**
 *  Get appender by log event.
 *
 *  @param event Log event
 *
 *  @return Log file appender
 */
+ (GTAppender *)appender:(GTLogEvent *)event;

@end
