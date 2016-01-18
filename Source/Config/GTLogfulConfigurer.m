//
//  GTLogfulConfigurer.m
//  LogLibrary
//
//  Created by Keith Ellis on 16/1/14.
//  Copyright © 2016年 getui. All rights reserved.
//

#import "GTAppenderManager.h"
#import "GTDateTimeUtil.h"
#import "GTLogStorage.h"
#import "GTLogUtil.h"
#import "GTLogfulConfigurer.h"
#import "GTLoggerConstants.h"
#import "GTScheduleManager.h"

NSString *const KEY_ON = @"on";
NSString *const KEY_INTERRUPT = @"interrupt";
NSString *const KEY_FREQUENCY = @"frequency";
NSString *const KEY_INTERVAL = @"interval";
NSString *const KEY_TIMESTAMP = @"timestamp";

@interface GTLogfulConfigurer ()

@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL interrupt;
@property (nonatomic, assign) int64_t frequency;
@property (nonatomic, assign) int64_t interval;
@property (nonatomic, assign) int64_t timestamp;

@end

@implementation GTLogfulConfigurer

+ (instancetype)configurer {
    static GTLogfulConfigurer *configurer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configurer = [[self alloc] init];
    });
    return configurer;
}

+ (void)parse:(NSDictionary *)dictionary save:(BOOL)save implement:(BOOL)implement {
    [[GTLogfulConfigurer configurer] _parse:dictionary save:save implement:implement];
}

+ (void)setOn:(BOOL)on save:(BOOL)save implement:(BOOL)implement {
    [[GTLogfulConfigurer configurer] setOn:on];
    if (save) {
        [[GTLogfulConfigurer configurer] save];
    }
    if (implement) {
        [[GTLogfulConfigurer configurer] implement];
    }
}

+ (void)setFrequency:(int64_t)frequency save:(BOOL)save implement:(BOOL)implement {
    [[GTLogfulConfigurer configurer] setFrequency:frequency];
    if (save) {
        [[GTLogfulConfigurer configurer] save];
    }
    if (implement) {
        [[GTLogfulConfigurer configurer] implement];
    }
}

+ (BOOL)isOn {
    return [GTLogfulConfigurer configurer].on;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (void)_parse:(NSDictionary *)dictionary save:(BOOL)save implement:(BOOL)implement {
    if (dictionary) {
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            if ([key isEqualToString:KEY_ON]) {
                _on = [obj boolValue];
            }
            if ([key isEqualToString:KEY_INTERRUPT]) {
                _interrupt = [obj boolValue];
            }
            if ([key isEqualToString:KEY_FREQUENCY]) {
                _frequency = [obj integerValue];
            }
            if ([key isEqualToString:KEY_INTERVAL]) {
                _interval = [obj integerValue];
            }
            if ([key isEqualToString:KEY_TIMESTAMP]) {
                _timestamp = [obj integerValue];
            }
        }];
        if (save) {
            [self save];
        }
        if (implement) {
            [self implement];
        }
    }
}

- (void)load {
    NSString *filePath = [GTLogStorage systemConfigFilePath];
    if (filePath != nil) {
        BOOL isDir;
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        if (exist && !isDir) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
            if (dictionary) {
                [self _parse:dictionary save:NO implement:NO];
            }
        }
    }
}

- (void)save {
    NSString *filePath = [GTLogStorage systemConfigFilePath];
    if (filePath != nil) {
        NSDictionary *dictionary = @{ KEY_ON : @(_on),
                                      KEY_INTERRUPT : @(_interrupt),
                                      KEY_FREQUENCY : @(_frequency),
                                      KEY_INTERVAL : @(_interval),
                                      KEY_TIMESTAMP : @(_timestamp) };
        [dictionary writeToFile:filePath atomically:YES];
    }
}

- (void)implement {
    if (_on) {
        [GTAppenderManager readCache];
        if (_timestamp != 0 && _interval != 0) {
            int64_t remain = _interval - ([GTDateTimeUtil currentTimeMillis] / 1000 - _timestamp);
            if (remain > 0) {
                [GTScheduleManager schedule:_frequency interrupt:_interrupt interval:remain];
            } else {
                [GTLogUtil d:NSStringFromClass(self.class) msg:@"Interval time arrived!"];
            }
        } else {
            [GTScheduleManager schedule:_frequency interrupt:false interval:0];
        }
    } else {
        [GTScheduleManager cancel];
    }
}

@end
