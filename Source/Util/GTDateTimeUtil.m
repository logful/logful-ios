//
//  DateTimeUtil.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTDateTimeUtil.h"

@implementation GTDateTimeUtil

+ (NSString *)dateString {
    NSDate *date = [NSDate date];
    return [GTDateTimeUtil formatDate:date formatter:@"yyyyMMdd"];
}

+ (NSString *)timeString {
    NSDate *date = [NSDate date];
    return [GTDateTimeUtil formatDate:date formatter:@"yyyyMMdd HH:mm:ss"];
}

+ (NSString *)timeString:(int64_t)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    return [GTDateTimeUtil formatDate:date formatter:@"yyyyMMdd HH:mm:ss"];
}

+ (NSString *)formatDate:(NSDate *)date formatter:(NSString *)formatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:date];
}

+ (int64_t)currentTimeMillis {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

+ (int64_t)dayStartTimestamp {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear |
                                                        NSCalendarUnitMonth |
                                                        NSCalendarUnitDay |
                                                        NSCalendarUnitHour |
                                                        NSCalendarUnitMinute |
                                                        NSCalendarUnitSecond
                                               fromDate:[NSDate date]];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *date = [calendar dateFromComponents:components];
    return [date timeIntervalSince1970] * 1000;
}

@end
