//
//  GTFileManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTFileManager.h"

@interface GTFileManager ()

@property (nonatomic, strong, nonnull) NSString *filePath;

@end

@implementation GTFileManager

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)write:(NSData *)data {
    // Rewrite
}

- (unsigned long long)available {
    return 0;
}

- (void)flush {
    // Rewrite
}

- (void)close {
    // Rewrite
}

- (void)releaseManager {
    // Rewrite
}

@end
