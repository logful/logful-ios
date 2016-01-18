//
//  GTScheduleManager.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTScheduleManager : NSObject

+ (void)schedule:(int64_t)frequency interrupt:(BOOL)interrupt interval:(int64_t)interval;
+ (void)cancel;

@end
