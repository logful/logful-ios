//
//  BaseLogEvent.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLogEvent.h"
#import <Foundation/Foundation.h>

@interface GTBaseLogEvent : GTLogEvent

+ (GTBaseLogEvent *__nonnull)createEvent:(NSString *__nonnull)loggerName
                                   level:(int)level
                                     tag:(NSString *__nonnull)tag
                                 message:(NSString *__nonnull)message
                            layoutString:(NSString *__nonnull)layoutString;

+ (GTBaseLogEvent *__nonnull)createEvent:(NSString *__nonnull)loggerName
                                   level:(int)level
                                     tag:(NSString *__nonnull)tag
                                 message:(NSString *__nonnull)message
                            layoutString:(NSString *__nonnull)layoutString
                            attachmentId:(int32_t)attachmentId;

@end
