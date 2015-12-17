//
//  GTSystemConfig.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/9.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTSystemConfig : NSObject

+ (void)read;

+ (void)saveAlias:(NSString *)alias;
+ (void)saveBaseUrl:(NSString *)url;
+ (void)saveStatus:(BOOL)on;

+ (void)saveAppKey:(NSString *)appKey;
+ (void)saveAppSecret:(NSString *)appSecret;

+ (NSString *)baseUrl;
+ (NSString *)alias;
+ (BOOL)isON;
+ (NSString *)appKey;
+ (NSString *)appSecret;

+ (NSURL *)apiUrl:(NSString *)uri;

@end
