//
//  GTSystemConfig.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/9.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTSystemConfig.h"
#import "GTLoggerConstants.h"
#import "GTLogStorage.h"
#import "GTStringUtils.h"

@interface GTSystemConfig ()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *aliasName;
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
    [config readUserPreferenceFile];
    [config readSystemConfig];
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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.on = YES;
        self.aliasName = @"";
    }
    return self;
}

/**
 *  Read user preference file.
 *
 * <?xml version="1.0" encoding="UTF-8"?>
 * <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 * <plist version="1.0">
 * <dict>
 * <key>baseUrl</key>
 * <string>http://127.0.0.1</string>
 * </dict>
 * </plist>
 */
- (void)readUserPreferenceFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:USER_PREFERENCE_FILE_NAME];

    BOOL isDir;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
    if (exist && !isDir) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        _baseUrl = [dictionary objectForKey:@"baseUrl"];
    }
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
