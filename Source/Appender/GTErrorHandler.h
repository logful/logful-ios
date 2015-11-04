//
//  ErrorHandler.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLogEvent;

@interface GTErrorHandler : NSObject

- (void)error:(NSString *)msg;
- (void)error:(NSString *)msg event:(GTLogEvent *)event error:(NSError *)error;
- (void)error:(NSString *)msg error:(NSError *)error;

@end
