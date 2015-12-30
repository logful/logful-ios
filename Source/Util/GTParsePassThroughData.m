//
//  GTParsePassThroughData.m
//  LogLibrary
//
//  Created by lqynydyxf on 15/12/30.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTParsePassThroughData.h"
#import "GTLoggerFactory.h"
#import "GTLogUtil.h"

@implementation GTParsePassThroughData

+ (NSDictionary*)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        [GTLogUtil d:TAG msg:@"json解析失败" err:err];
        return nil;
    }
    return dic;
}

+ (void)parseData:(NSString *)jsonString{
    NSDictionary *msgDict = [GTParsePassThroughData dictionaryWithJsonString:jsonString];
    int openLog = [[msgDict objectForKey:@"on"] intValue];
    long interval = [[msgDict objectForKey:@"interval"] longValue];
    long frequency = [[msgDict objectForKey:@"frequency"] longValue];
//    NSLog(@"openLog---%d", openLog);
//    NSLog(@"interval---%ld", interval);
//    NSLog(@"frequency---%ld", frequency);
    [GTLogUtil d:@"****openLog****" msg:[NSString stringWithFormat:@"%d", openLog]];
    [GTLogUtil d:@"****interval***" msg:[NSString stringWithFormat:@"%ld", interval]];
    [GTLogUtil d:@"****frequency" msg:[NSString stringWithFormat:@"%ld", frequency]];
    if (openLog == 1) {
        [GTLoggerFactory turnOn];
        [GTLoggerFactory interruptThenSync];
//        [self loopExcuteWithInterval:interval andFrequency:frequency];
    }else{
        [GTLoggerFactory turnOff];
    };
}

+ (void)loopExcuteWithInterval:(long)interval andFrequency:(long)frequency{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:frequency target:self selector:@selector(AnZai:) userInfo:nil repeats:YES];
}

- (void)AnZai:(NSTimer *) timer{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
//    NSLog(@"Time is %@", date);
    NSLog(@"NSTimer********************NSTimer");
}

@end
