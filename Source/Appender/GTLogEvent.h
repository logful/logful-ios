//
//  LogEvent.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLogEvent : NSObject

- (int)getLevel;

- (int)getPriority;

- (NSString *)getLoggerName;

- (NSString *)getTag;

- (NSString *)getMessage;

- (int64_t)getTimeMillis;

- (int16_t)getLayoutId;

- (NSString *)getDateString;

- (NSString *)getThreadName;

- (int32_t)getAttachmentId;

@end
