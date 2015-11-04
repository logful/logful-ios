//
//  GTAppenderOperation.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTAppenderOperation.h"
#import "GTBaseAppender.h"
#import "GTBaseLogEvent.h"
#import "GTAppenderManager.h"
#import "GTConstants.h"

#define kGTAppenderOperationLockName @"com.getui.log.appender.operation.lock"
#define IOS_8_OR_LATER [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending

typedef NS_ENUM(NSInteger, GTOperationState) {
    GTOperationStatePaused = -1,
    GTOperationStateReady = 1,
    GTOperationStateExecuting = 2,
    GTOperationStateFinished = 3,
};

static inline NSString *GTKeyPathFromOperationState(GTOperationState state) {
    switch (state) {
        case GTOperationStateReady:
            return @"isReady";
        case GTOperationStateExecuting:
            return @"isExecuting";
        case GTOperationStateFinished:
            return @"isFinished";
        case GTOperationStatePaused:
            return @"isPaused";
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"state";
#pragma clang diagnostic pop
        }
    }
}

static inline BOOL GTStateTransitionIsValid(GTOperationState fromState, GTOperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case GTOperationStateReady:
            switch (toState) {
                case GTOperationStatePaused:
                case GTOperationStateExecuting:
                    return YES;
                case GTOperationStateFinished:
                    return isCancelled;
                default:
                    return NO;
            }
        case GTOperationStateExecuting:
            switch (toState) {
                case GTOperationStatePaused:
                case GTOperationStateFinished:
                    return YES;
                default:
                    return NO;
            }
        case GTOperationStateFinished:
            return NO;
        case GTOperationStatePaused:
            return toState == GTOperationStateReady;
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            switch (toState) {
                case GTOperationStatePaused:
                case GTOperationStateReady:
                case GTOperationStateExecuting:
                case GTOperationStateFinished:
                    return YES;
                default:
                    return NO;
            }
        }
#pragma clang diagnostic pop
    }
}

@interface GTAppenderOperation ()

@property (nonatomic, assign) GTOperationState state;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) GTLogEvent *event;

@end

@implementation GTAppenderOperation

- (instancetype)initWithEvent:(GTLogEvent *)event {
    self = [super init];
    if (!self) {
        return nil;
    }

    _state = GTOperationStateReady;

    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = kGTAppenderOperationLockName;

    self.event = event;

    if (IOS_8_OR_LATER) {
        int level = [self.event getLevel];
        switch (level) {
            case LEVEL_VERBOSE:
                self.queuePriority = NSOperationQueuePriorityVeryLow;
                break;
            case LEVEL_DEBUG:
                self.queuePriority = NSOperationQueuePriorityLow;
                break;
            case LEVEL_INFO:
                self.queuePriority = NSOperationQueuePriorityNormal;
                break;
            case LEVEL_WARN:
                self.queuePriority = NSOperationQueuePriorityNormal;
                break;
            case LEVEL_ERROR:
                self.queuePriority = NSOperationQueuePriorityHigh;
                break;
            case LEVEL_EXCEPTION:
                self.queuePriority = NSOperationQueuePriorityHigh;
                break;
            case LEVEL_FATAL:
                self.queuePriority = NSOperationQueuePriorityVeryHigh;
                break;
            default:
                break;
        }
    }

    return self;
}

- (void)setState:(GTOperationState)state {
    if (!GTStateTransitionIsValid(self.state, state, [self isCancelled])) {
        return;
    }

    [self.lock lock];
    NSString *oldStateKey = GTKeyPathFromOperationState(self.state);
    NSString *newStateKey = GTKeyPathFromOperationState(state);

    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [self.lock unlock];
}

- (BOOL)isPaused {
    return self.state == GTOperationStatePaused;
}

- (BOOL)isReady {
    return self.state == GTOperationStateReady && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == GTOperationStateExecuting;
}

- (BOOL)isFinished {
    return self.state == GTOperationStateFinished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    [self.lock lock];
    self.state = GTOperationStateExecuting;

    GTAppender *appender = [GTAppenderManager appender:self.event];
    if (appender != nil && self.event != nil) {
        [appender append:self.event];
    }

    [self.lock unlock];

    [self finish];
}

- (void)pause {
    // TODO
}

- (void)resume {
    // TODO
}

- (void)finish {
    [self.lock lock];
    self.state = GTOperationStateFinished;
    [self.lock unlock];
}

- (void)cancel {
    // TODO
}

- (void)dealloc {
    self.event = nil;
}

@end
