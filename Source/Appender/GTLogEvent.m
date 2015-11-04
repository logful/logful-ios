//
//  LogEvent.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLogEvent.h"
#import "GTDateTimeUtil.h"

@implementation GTLogEvent

- (int)getLevel {
    return 0;
}

- (int)getPriority {
    return 0;
}

- (NSString *)getLoggerName {
    return @"";
}

- (NSString *)getTag {
    return @"";
}

- (NSString *)getMessage {
    return @"";
}

- (int16_t)getLayoutId {
    return 0;
}

- (int64_t)getTimeMillis {
    return 0;
}

- (NSString *)getDateString {
    return @"";
}

- (NSString *)getThreadName {
    return [NSString stringWithFormat:@"%@", [NSThread currentThread]];
}

- (long)getSequence {
    return 0;
}

- (int32_t)getAttachmentId {
    return -1;
}

@end
