//
//  BaseLogEvent.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTBaseLogEvent.h"
#import "GTDateTimeUtil.h"
#import "GTDatabaseManager.h"

@interface GTBaseLogEvent ()

@property (nonnull, nonatomic, strong) NSString *loggerName;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int priority;
@property (nonnull, nonatomic, strong) NSString *tag;
@property (nonnull, nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *layoutString;
@property (nonatomic, assign) int64_t timestamp;
@property (nonatomic, assign) int32_t attachmentId;

@end

@implementation GTBaseLogEvent

+ (GTBaseLogEvent *)createEvent:(NSString *)loggerName
                          level:(int)level
                            tag:(NSString *)tag
                        message:(NSString *)message
                   layoutString:(NSString *)layoutString {
    GTBaseLogEvent *logEvent = [[GTBaseLogEvent alloc] init];
    logEvent.loggerName = [loggerName copy];
    logEvent.level = level;
    logEvent.priority = level;
    logEvent.tag = [tag copy];
    logEvent.message = [message copy];
    logEvent.layoutString = [layoutString copy];
    return logEvent;
}

+ (GTBaseLogEvent *)createEvent:(NSString *)loggerName
                          level:(int)level
                            tag:(NSString *)tag
                        message:(NSString *)message
                   layoutString:(NSString *)layoutString
                   attachmentId:(int32_t)attachmentId {
    GTBaseLogEvent *logEvent = [[GTBaseLogEvent alloc] init];
    logEvent.loggerName = [loggerName copy];
    logEvent.level = level;
    logEvent.priority = level;
    logEvent.tag = [tag copy];
    logEvent.message = [message copy];
    logEvent.layoutString = [layoutString copy];
    logEvent.attachmentId = attachmentId;
    return logEvent;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timestamp = [GTDateTimeUtil currentTimeMillis];
        self.attachmentId = -1;
    }
    return self;
}

- (int)getLevel {
    return _level;
}

- (int)getPriority {
    return _priority;
}

- (NSString *)getLoggerName {
    return _loggerName;
}

- (NSString *)getTag {
    return _tag;
}

- (NSString *)getMessage {
    return _message;
}

- (int64_t)getTimeMillis {
    return _timestamp;
}

- (int16_t)getLayoutId {
    return [[GTDatabaseManager manager] layoutId:_layoutString];
}

- (int32_t)getAttachmentId {
    return _attachmentId;
}

@end
