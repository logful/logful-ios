//
//  GTScheduleTask.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTScheduleTask.h"

@interface GTScheduleTask ()

@property (nonatomic, strong) NSString *name;

@end

@implementation GTScheduleTask

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}

- (NSString *)getName {
    return self.name;
}

- (void)execute {
    // Rewrite
}

@end
