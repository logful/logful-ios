//
//  GTScheduleTask.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTScheduleTask : NSObject

- (instancetype)initWithName:(NSString *)name;

/**
 *  Get schedule task name.
 *
 *  @return Task name
 */
- (NSString *)getName;

/**
 *  Excute task.
 */
- (void)execute;

@end
