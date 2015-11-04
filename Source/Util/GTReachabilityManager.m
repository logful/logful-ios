//
//  GTReachabilityManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/30.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTReachabilityManager.h"
#import "GTReachability.h"
#import "GTLoggerFactory.h"
#import "GTLoggerConfigurator.h"

@interface GTReachabilityManager ()

@property (nonatomic, strong) GTReachability *reachability;

@end

@implementation GTReachabilityManager

+ (id)manager {
    static GTReachabilityManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.reachability = [GTReachability reachabilityForInternetConnection];
    }
    return self;
}

+ (BOOL)shouldUpload {
    GTLoggerConfigurator *config = [GTLoggerFactory config];
    if (config != nil) {
        GTReachabilityManager *manager = [GTReachabilityManager manager];
        GTNetworkStatus status = [manager.reachability currentReachabilityStatus];
        NSArray *networkTypes = config.uploadNetworkType;
        for (NSNumber *number in networkTypes) {
            if (status == [number integerValue]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
