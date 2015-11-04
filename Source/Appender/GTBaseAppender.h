//
//  BaseAppender.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/28.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTAppender.h"
#import <Foundation/Foundation.h>

@interface GTBaseAppender : GTAppender

- (instancetype)initWithLoggerName:(NSString *)loggerName
                          filePath:(NSString *)filePath
                            layout:(GTLayout *)layout
                          capacity:(unsigned long long)capacity
                          fragment:(int)fragment
                       ignoreError:(BOOL)ignoreError
                    immediateFlush:(BOOL)immediateFlush;

@end
