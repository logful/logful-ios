//
//  GTConfig.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/15.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTConfig.h"

@implementation GTConfig

+ (GTConfig *)defaultConfig {
    GTConfig *config = [[GTConfig alloc] init];
    config.shouldUpload = NO;
    return config;
}

@end
