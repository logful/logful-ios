//
//  GTSystemConfig.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/9.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTLogStorage.h"
#import "GTLoggerConstants.h"
#import "GTStringUtils.h"
#import "GTSystemConfig.h"

@interface GTSystemConfig ()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *aliasName;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;

@end

@implementation GTSystemConfig

+ (id)config {
    static GTSystemConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

+ (void)saveBaseUrl:(NSString *)url {
    GTSystemConfig *config = [GTSystemConfig config];
    config.baseUrl = url;
}

+ (void)saveAlias:(NSString *)alias {
    GTSystemConfig *config = [GTSystemConfig config];
    config.aliasName = alias;
}

+ (void)saveAppKey:(NSString *)appKey {
    GTSystemConfig *config = [GTSystemConfig config];
    config.appKey = appKey;
}

+ (void)saveAppSecret:(NSString *)appSecret {
    GTSystemConfig *config = [GTSystemConfig config];
    config.appSecret = appSecret;
}

+ (NSString *)baseUrl {
    GTSystemConfig *config = [GTSystemConfig config];
    if ([GTStringUtils isEmpty:config.baseUrl]) {
        return API_BASE_URL;
    }
    return config.baseUrl;
}

+ (NSString *)alias {
    GTSystemConfig *config = [GTSystemConfig config];
    if ([GTStringUtils isEmpty:config.aliasName]) {
        return @"";
    }
    return config.aliasName;
}

+ (NSString *)appKey {
    GTSystemConfig *config = [GTSystemConfig config];
    return config.appKey;
}

+ (NSString *)appSecret {
    GTSystemConfig *config = [GTSystemConfig config];
    return config.appSecret;
}

+ (NSURL *)apiUrl:(NSString *)uri {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [GTSystemConfig baseUrl], uri]];
}

@end
