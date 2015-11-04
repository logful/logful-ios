//
//  GTUncaughtExceptionHandler.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/6.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GTUncaughtExceptionHandler : NSObject

void SetUncaughtExceptionHandler(void);

+ (instancetype)handler;

@end
