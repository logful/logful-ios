//
//  GTConfig.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/15.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTConfig : NSObject

@property (nonatomic, assign) int16_t level;
@property (nonatomic, assign) int16_t targetLevel;
@property (nonatomic, assign) BOOL shouldUpload;
@property (nonatomic, assign) int16_t scheduleType;
@property (nonatomic, assign) int64_t scheduleTime;
@property (nonatomic, strong) NSArray *scheduleArray;

@property (nonatomic, assign) BOOL upload;

+ (GTConfig *)defaultConfig;

@end
