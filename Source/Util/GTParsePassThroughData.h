//
//  GTParsePassThroughData.h
//  LogLibrary
//
//  Created by lqynydyxf on 15/12/30.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *TAG = @"GTParsePassThroughData";

@interface GTParsePassThroughData : NSObject

//把JSON格式的字符串转换成字典
+ (NSDictionary*)dictionaryWithJsonString:(NSString*)jsonString;

+ (void)parseData:(NSString*)jsonString;

+ (void)loopExcuteWithInterval:(long)interval andFrequency:(long)frequency;

- (void)handleTimer:(NSTimer *) timer;

@end
