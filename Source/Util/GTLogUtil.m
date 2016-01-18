//
//  GTLogUtil.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/12/24.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTLogUtil.h"
#import "GTLoggerFactory.h"

#define DEBUG_TAG @"LOGFUL [DEBUG]"
#define INFO_TAG @"LOGFUL [INFO]"
#define VERBOSE_TAG @"LOGFUL [VERBOSE]"
#define WARN_TAG @"LOGFUL [WARN]"
#define ERROR_TAG @"LOGFUL [ERROR]"
#define FATAL_TAG @"LOGFUL [FATAL]"

@implementation GTLogUtil

+ (void)d:(NSString *)tag msg:(NSString *)msg {
    [[self class] log:DEBUG_TAG tag:tag msg:msg err:nil];
}

+ (void)d:(NSString *)tag msg:(NSString *)msg err:(NSError *)err {
    [[self class] log:DEBUG_TAG tag:tag msg:msg err:err];
}

+ (void)i:(NSString *)tag msg:(NSString *)msg {
    [[self class] log:INFO_TAG tag:tag msg:msg err:nil];
}

+ (void)i:(NSString *)tag msg:(NSString *)msg err:(NSError *)err {
    [[self class] log:INFO_TAG tag:tag msg:msg err:err];
}

+ (void)v:(NSString *)tag msg:(NSString *)msg {
    [[self class] log:VERBOSE_TAG tag:tag msg:msg err:nil];
}

+ (void)v:(NSString *)tag msg:(NSString *)msg err:(NSError *)err {
    [[self class] log:VERBOSE_TAG tag:tag msg:msg err:err];
}

+ (void)w:(NSString *)tag msg:(NSString *)msg {
    [[self class] log:WARN_TAG tag:tag msg:msg err:nil];
}

+ (void)w:(NSString *)tag err:(NSError *)err {
    [[self class] log:WARN_TAG tag:tag msg:nil err:err];
}

+ (void)w:(NSString *)tag msg:(NSString *)msg err:(NSError *)err {
    [[self class] log:WARN_TAG tag:tag msg:msg err:err];
}

+ (void)e:(NSString *)tag msg:(NSString *)msg {
    [[self class] log:ERROR_TAG tag:tag msg:msg err:nil];
}

+ (void)e:(NSString *)tag msg:(NSString *)msg err:(NSError *)err {
    [[self class] log:ERROR_TAG tag:tag msg:msg err:err];
}

+ (void)f:(NSString *)tag msg:(NSString *)msg {
    [[self class] log:FATAL_TAG tag:tag msg:msg err:nil];
}

+ (void)f:(NSString *)tag err:(NSError *)err {
    [[self class] log:FATAL_TAG tag:tag msg:nil err:err];
}

+ (void)f:(NSString *)tag msg:(NSString *)msg err:(NSError *)err {
    [[self class] log:FATAL_TAG tag:tag msg:msg err:err];
}

+ (void)log:(NSString *)levelTag tag:(NSString *)tag msg:(NSString *)msg err:(NSError *)err {
    if ([GTLoggerFactory isDebugMode]) {
        if (err) {
            if (!msg) {
                NSLog(@"%@: %@\n%@", levelTag, tag, err.description);
            } else {
                NSLog(@"%@: %@: %@\n%@", levelTag, tag, msg, err.description);
            }
        } else {
            NSLog(@"%@: %@: %@", levelTag, tag, msg);
        }
    }
}

@end
