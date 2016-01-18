//
//  GTScheduleManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTAppenderManager.h"
#import "GTClearScheduleTask.h"
#import "GTDateTimeUtil.h"
#import "GTLogUtil.h"
#import "GTLoggerConfigurator.h"
#import "GTLoggerFactory.h"
#import "GTMutableDictionary.h"
#import "GTRefreshScheduleTask.h"
#import "GTScheduleManager.h"
#import "GTTransferManager.h"
#import "GTUploadScheduleTask.h"

@interface GTScheduleManager ()

@property (nonatomic, strong) GTMutableDictionary *scheduleDictionary;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) int64_t startTime;
@property (nonatomic, assign) int64_t interval;
@property (nonatomic, assign) BOOL interrupt;

@end

@implementation GTScheduleManager

+ (instancetype)manager {
    static GTScheduleManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)schedule:(int64_t)frequency interrupt:(BOOL)interrupt interval:(int64_t)interval {
    [[GTScheduleManager manager] _schedule:frequency interrupt:interrupt interval:interval];
}

+ (void)cancel {
    GTScheduleManager *manager = [GTScheduleManager manager];
    if (manager.timer) {
        dispatch_source_cancel(manager.timer);
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("com.getui.log.schedule.manager.task", NULL);
    }
    return self;
}

- (void)_schedule:(int64_t)frequency interrupt:(BOOL)interrupt interval:(int64_t)interval {
    _interrupt = interrupt;
    _interval = interval;
    __weak GTScheduleManager *weak = self;
    [GTLogUtil d:NSStringFromClass(self.class) msg:[NSString stringWithFormat:@"Schedule task every %lld seconds.", frequency]];
    if (!_timer) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
        dispatch_source_set_event_handler(_timer, ^{
            [weak schuduleEvent];
        });
        dispatch_source_set_cancel_handler(_timer, ^{
            _timer = nil;
            [GTLogUtil d:NSStringFromClass(self.class) msg:@"Schedule timer canceled!"];
        });
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), frequency * NSEC_PER_SEC, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), _queue, ^{
            dispatch_resume(_timer);
        });
    } else {
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), frequency * NSEC_PER_SEC, 0);
    }
    _startTime = [GTDateTimeUtil currentTimeMillis] / 1000;

    if (interval != 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), _queue, ^{
            if ([GTDateTimeUtil currentTimeMillis] / 1000 - _startTime >= _interval) {
                if (weak.timer) {
                    dispatch_source_cancel(weak.timer);
                }
            }
        });
    }
}

- (void)schuduleEvent {
    [GTLogUtil d:NSStringFromClass(self.class) msg:@"Schedule task triger!"];
    if (_interrupt) {
        [GTAppenderManager interrupt];
        [GTLogUtil d:NSStringFromClass(self.class) msg:@"Will interrupt all writing log file."];
    }
    [GTTransferManager uploadLogFile];
    [GTTransferManager uploadAttachment];
}

@end
