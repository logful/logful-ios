//
//  GTUncaughtExceptionHandler.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/6.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTUncaughtExceptionHandler.h"

static NSUncaughtExceptionHandler *defaultUncaughtExceptionHandler;

@interface GTUncaughtExceptionHandler () <UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isStoped;

@end

@implementation GTUncaughtExceptionHandler

void handleException(NSException *exception) {
    [[GTUncaughtExceptionHandler handler] showCrashView];
}

void handleSignal(int signal) {
}

void SetUncaughtExceptionHandler(void) {
    defaultUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&handleException);

    signal(SIGABRT, handleSignal);
    signal(SIGILL, handleSignal);
    signal(SIGSEGV, handleSignal);
    signal(SIGFPE, handleSignal);
    signal(SIGBUS, handleSignal);
    signal(SIGPIPE, handleSignal);
}

+ (instancetype)handler {
    static GTUncaughtExceptionHandler *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[self alloc] init];
    });
    return handler;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isStoped = NO;
    }
    return self;
}

- (void)showCrashView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Caught Crash"
                                                    message:@"Crash message"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];

    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    } while (!self.isStoped);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.isStoped = YES;
}

@end
