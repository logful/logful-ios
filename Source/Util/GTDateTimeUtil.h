//
//  DateTimeUtil.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTDateTimeUtil : NSObject

+ (NSString *)dateString;
+ (NSString *)timeString;
+ (NSString *)timeString:(int64_t)timestamp;
+ (int64_t)currentTimeMillis;
+ (int64_t)dayStartTimestamp;

@end
