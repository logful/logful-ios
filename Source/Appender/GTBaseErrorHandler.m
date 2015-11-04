//
//  BaseErrorHandler.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/10.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTBaseErrorHandler.h"

@implementation GTBaseErrorHandler

- (void)error:(NSString *)msg {
    if (msg != nil) {
        NSLog(@"%@", msg);
    }
}

- (void)error:(NSString *)msg event:(GTLogEvent *)event error:(NSError *)error {
    //TODO
}

- (void)error:(NSString *)msg error:(NSError *)error {
    //TODO
}

@end
