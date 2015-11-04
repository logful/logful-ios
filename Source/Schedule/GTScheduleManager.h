//
//  GTScheduleManager.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTScheduleManager : NSObject

+ (void)schedule;
+ (void)scheduleWithTime:(int64_t)scheduleTime;
+ (void)scheduleWithArray:(NSString *)scheduleArray;

@end
