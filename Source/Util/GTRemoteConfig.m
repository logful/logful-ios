//
//  GTRemoteConfig.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/14.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTRemoteConfig.h"
#import "GTConfig.h"
#import "GTTransferManager.h"
#import "GTScheduleManager.h"
#import "GTUploadSystemInfoOperation.h"

@interface GTRemoteConfig () <GTUploadSystemInfoOperationDelegate>

@end

@implementation GTRemoteConfig

+ (instancetype)config {
    static GTRemoteConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc] init];
    });
    return config;
}

+ (void)read {
    GTRemoteConfig *config = [GTRemoteConfig config];

    GTUploadSystemInfoOperation *operation = [[GTUploadSystemInfoOperation alloc] init];
    operation.operationDelegate = config;
    [[[NSOperationQueue alloc] init] addOperation:operation];
}

- (void)parse:(GTConfig *)config {
    if (config.shouldUpload) {
        if (config.scheduleType == 1) {

        } else if (config.scheduleType == 2) {
        }
        // TODO
        [GTScheduleManager schedule];
    }
}

#pragma mark - GTUploadSystemInfoOperationDelegate

- (void)didResponse:(NSData *)data {
    GTConfig *config = [GTConfig defaultConfig];

    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!error) {
        NSInteger level = [[dictionary objectForKey:@"level"] integerValue];
        NSInteger targetLevel = [[dictionary objectForKey:@"targetLevel"] integerValue];
        config.shouldUpload = level <= targetLevel;
    }

    [self parse:config];
}

- (void)didFailure {
    [self parse:[GTConfig defaultConfig]];
}

@end
