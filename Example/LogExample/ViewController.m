//
//  ViewController.m
//  LogExample
//
//  Created by Keith Ellis on 15/8/5.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "ViewController.h"
#import <LogLibrary/LogLibrary.h>

@interface ViewController ()

@property (nonatomic, strong) GTLogger *logger;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.logger = [GTLoggerFactory logger:@"app"];
    [self.logSwitch setOn:[GTLoggerFactory isOn]];

    [GTLoggerFactory bindAlias:@"alias"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)verbose:(id)sender {
    GLOG_VERBOSE(@"ViewController", @"some|verbose|message");
}

- (IBAction)debug:(id)sender {
    GLOG_DEBUG(@"ViewController", @"some|debug|message");
}

- (IBAction)info:(id)sender {
    GLOG_INFO(@"ViewController", @"some|info|message");
}

- (IBAction)warn:(id)sender {
    GLOG_WARN(@"ViewController", @"some|warn|message");
}

- (IBAction)error:(id)sender {
    GLOG_ERROR(@"ViewController", @"some|error|message");
}

- (IBAction)exception:(id)sender {
    GLOG_EXCEPTION(@"ViewController", @"some|exception|message");
}

- (IBAction)fatal:(id)sender {
    GLOG_FATAL(@"ViewController", @"some|fatal|message");
}

- (IBAction)batch:(id)sender {
    for (NSUInteger i = 0; i < 1000; i++) {
        NSString *msg = [[NSUUID UUID] UUIDString];
        [_logger verbose:@"ViewController" msg:msg];
        [_logger debug:@"ViewController" msg:msg];
        [_logger info:@"ViewController" msg:msg];
        [_logger warn:@"ViewController" msg:msg];
        [_logger error:@"ViewController" msg:msg];
        [_logger exception:@"ViewController" msg:msg];
        [_logger fatal:@"ViewController" msg:msg];
    }
}

- (IBAction)upload:(id)sender {
    [GTLoggerFactory sync];
}

- (IBAction)crash:(id)sender {
    [NSException raise:NSInvalidArgumentException format:@"Force crash"];
}

- (IBAction)interrput:(id)sender {
    [GTLoggerFactory interruptThenSync];
}

- (IBAction)changeStatus:(id)sender {
    UISwitch *logSwitch = (UISwitch *) sender;
    if ([logSwitch isOn]) {
        [GTLoggerFactory turnOn];
    } else {
        [GTLoggerFactory turnOff];
    }
}

- (IBAction)captureScreen:(id)sender {
    GLOG_DEBUG_CAPTURE(@"ViewController", @"some|debug|message with capture");
}

@end
