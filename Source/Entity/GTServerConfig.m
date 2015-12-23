//
//  GTConfig.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/15.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTServerConfig.h"

@implementation GTServerConfig

- (instancetype)init {
    return nil;
}

- (instancetype)initWithAttr:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        @try {
            self.granted = [[dictionary valueForKeyPath:@"granted"] boolValue];
        }
        @catch (NSException *exception) {
            return nil;
        }
    }
    return self;
}

@end
