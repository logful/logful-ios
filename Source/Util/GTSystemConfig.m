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
@property (nonatomic, assign) BOOL on;

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

+ (void)read {
    GTSystemConfig *config = [GTSystemConfig config];
    [config readSystemConfig];
}

+ (void)saveBaseUrl:(NSString *)url {
    if (url == nil || url.length == 0) {
        return;
    }
    GTSystemConfig *config = [GTSystemConfig config];
    config.baseUrl = url;
}

+ (void)saveAlias:(NSString *)alias {
    if (alias == nil || alias.length == 0) {
        return;
    }
    GTSystemConfig *config = [GTSystemConfig config];
    config.aliasName = alias;
}

+ (void)saveStatus:(BOOL)on {
    GTSystemConfig *config = [GTSystemConfig config];
    if (on != config.on) {
        config.on = on;
        [config writeSystemConfig];
    }
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
    if (config.baseUrl == nil || config.baseUrl.length == 0) {
        return API_BASE_URL;
    }
    return config.baseUrl;
}

+ (NSString *)alias {
    GTSystemConfig *config = [GTSystemConfig config];
    if (config.aliasName == nil) {
        return @"";
    }
    return config.aliasName;
}

+ (BOOL)isON {
    GTSystemConfig *config = [GTSystemConfig config];
    return config.on;
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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.on = YES;
        self.aliasName = @"";
    }
    return self;
}

- (void)readSystemConfig {
    NSString *filePath = [GTLogStorage systemConfigFilePath];
    if (filePath != nil) {
        BOOL isDir;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        if (exist && !isDir) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
            id val = [dictionary objectForKey:@"isOn"];
            if (val != nil) {
                _on = [val boolValue];
            }
        }
    }
}

- (void)writeSystemConfig {
    // TODO
    NSString *filePath = [GTLogStorage systemConfigFilePath];
    if (filePath != nil) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:@(_on) forKey:@"isOn"];
        [dictionary writeToFile:filePath atomically:YES];
    }
}

@end
