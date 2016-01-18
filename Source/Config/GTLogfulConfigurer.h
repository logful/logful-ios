//
//  GTLogfulConfigurer.h
//  LogLibrary
//
//  Created by Keith Ellis on 16/1/14.
//  Copyright © 2016年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLogfulConfigurer : NSObject

+ (void)parse:(NSDictionary *)dictionary save:(BOOL)save implement:(BOOL)implement;
+ (void)setOn:(BOOL)on save:(BOOL)save implement:(BOOL)implement;
+ (void)setFrequency:(int64_t)frequency save:(BOOL)save implement:(BOOL)implement;
+ (BOOL)isOn;

@end
