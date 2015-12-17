//
//  GTUploadSystemInfoOperation.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTUploadSystemInfoOperation.h"
#import "GTDeviceID.h"
#import "GTMultipartInputStream.h"
#import "GTLogStorage.h"
#import "GTLoggerConstants.h"
#import "GTChecksum.h"
#import "GTSystemConfig.h"
#import "GTLoggerFactory.h"

@interface GTUploadSystemInfoOperation ()

@property (nonatomic, assign) BOOL successful;

@end

@implementation GTUploadSystemInfoOperation

- (NSString *)identifier {
    return [NSString stringWithFormat:@"%d-%d", 100, 3];
}

- (GTMultipartInputStream *)bodyStream {
    _successful = NO;

    NSString *uid = [GTDeviceID uid];

    GTMultipartInputStream *body = [[GTMultipartInputStream alloc] init];
    [body addPartWithName:@"platform" string:@"ios"];
    [body addPartWithName:@"sdkVersion" string:[GTLoggerFactory version]];
    [body addPartWithName:@"uid" string:uid];
    [body addPartWithName:@"alias" string:[GTSystemConfig alias]];
    [body addPartWithName:@"model" string:[UIDevice currentDevice].model];
    [body addPartWithName:@"imei" string:@""];
    [body addPartWithName:@"macAddress" string:@""];
    [body addPartWithName:@"osVersion" string:[UIDevice currentDevice].systemVersion];

    [body addPartWithName:@"appId" string:[[NSBundle mainBundle] bundleIdentifier]];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [body addPartWithName:@"version" string:infoDictionary[@"CFBundleVersion"]];
    [body addPartWithName:@"versionString" string:infoDictionary[@"CFBundleShortVersionString"]];

    return body;
}

- (NSURL *)url {
    /*
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                           [GTSystemConfig baseUrl],
                                                           UPLOAD_SYSTEM_INFO_URI]];
     */
    return nil;
}

- (void)success {
    _successful = YES;
}

- (void)response:(NSData *)data {
    if (_successful) {
        if (_operationDelegate != nil && [_operationDelegate respondsToSelector:@selector(didResponse:)]) {
            [_operationDelegate didResponse:data];
        }
    }
}

- (void)failure {
    if (_operationDelegate != nil && [_operationDelegate respondsToSelector:@selector(didFailure)]) {
        [_operationDelegate didFailure];
    }
}

@end
