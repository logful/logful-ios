//
//  StringUtils.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/27.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTStringUtils : NSObject

+ (BOOL)isEmpty:(NSString *)string;
+ (NSString *)propertiesDictionaryToString:(NSDictionary *)dictionary;
+ (NSString *)base64:(NSString *)string;

@end
