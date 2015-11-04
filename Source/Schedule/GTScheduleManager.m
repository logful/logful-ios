//
//  GTScheduleManager.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTScheduleManager.h"
#import "GTMutableDictionary.h"
#import "GTLoggerFactory.h"
#import "GTLoggerConfigurator.h"
#import "GTRefreshScheduleTask.h"
#import "GTUploadScheduleTask.h"
#import "GTClearScheduleTask.h"

@interface GTScheduleManager ()

@property (nonatomic, strong) GTMutableDictionary *scheduleDictionary;
@property (nonatomic, strong) dispatch_queue_t taskQueue;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation GTScheduleManager

+ (id)manager {
    static GTScheduleManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (void)schedule {
    GTScheduleManager *manager = [GTScheduleManager manager];
    [manager configScheduleTask];
    [manager startSchedule];
}

+ (void)scheduleWithTime:(int64_t)scheduleTime {
    // TODO
}

+ (void)scheduleWithArray:(NSString *)scheduleArray {
    // TODO
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.scheduleDictionary = [[GTMutableDictionary alloc] init];
    }
    return self;
}

- (void)configScheduleTask {
    GTRefreshScheduleTask *refreshTask = [[GTRefreshScheduleTask alloc] initWithName:@"Refresh"];
    [self.scheduleDictionary setObject:refreshTask forKey:[refreshTask getName]];

    GTUploadScheduleTask *uploadTask = [[GTUploadScheduleTask alloc] initWithName:@"Upload"];
    [self.scheduleDictionary setObject:uploadTask forKey:[uploadTask getName]];

    GTClearScheduleTask *clearTask = [[GTClearScheduleTask alloc] initWithName:@"Clear"];
    [self.scheduleDictionary setObject:clearTask forKey:[clearTask getName]];
}

- (void)startSchedule {
    GTLoggerConfigurator *config = [GTLoggerFactory config];
    if (config == nil) {
        return;
    }

    // Create task excute queue.
    self.taskQueue = dispatch_queue_create("com.getui.log.schedule.manager.task", NULL);

    // Create schedule timer.
    uint64_t interval = config.updateSystemFrequency * NSEC_PER_SEC;
    dispatch_queue_t queue = dispatch_queue_create("com.getui.log.schedule.manager.timer", NULL);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);

    __weak GTScheduleManager *weak = self;
    dispatch_source_set_event_handler(self.timer, ^() {
        [weak executeScheduleTask];
    });

    // Delay trigger timer.
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        dispatch_resume(weak.timer);
    });
}

- (void)executeScheduleTask {
    for (NSString *key in _scheduleDictionary.allKeys) {
        GTScheduleTask *task = [_scheduleDictionary objectForKey:key];
        dispatch_async(_taskQueue, ^{
            [task execute];
        });
    }
}

@end
