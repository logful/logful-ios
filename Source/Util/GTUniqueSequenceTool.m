//
//  GTUniqueSequenceTool.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/20.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTUniqueSequenceTool.h"
#import "GTDatabaseManager.h"
#include <libkern/OSAtomic.h>
#include <stdlib.h>

@interface GTUniqueSequenceTool ()

@property (nonatomic, assign) int32_t sequence;

@end

@implementation GTUniqueSequenceTool

+ (instancetype)tool {
    static GTUniqueSequenceTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] init];
    });
    return tool;
}

+ (int32_t)sequence {
    GTUniqueSequenceTool *tool = [GTUniqueSequenceTool tool];
    int32_t value = tool.sequence;
    [tool increment];
    return value;
}

- (void)increment {
    OSAtomicIncrement32Barrier(&_sequence);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        int maxSequence = [[GTDatabaseManager manager] findMaxAttachmentSequence];
        if (maxSequence == -1) {
            self.sequence = 1000000 + arc4random() % (6000000 - 1000000);
        } else {
            self.sequence = maxSequence + 1;
        }
    }
    return self;
}

@end
