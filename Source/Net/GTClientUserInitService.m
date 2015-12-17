//
//  GTClientUserAuthService.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/12/17.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTClientUserInitService.h"
#import "GTCryptoTool.h"
#import "GTDateTimeUtil.h"
#import "GTDeviceID.h"
#import "GTLoggerConstants.h"
#import "GTLoggerFactory.h"
#import "GTStringUtils.h"
#import "GTStringUtils.h"
#import "GTSystemConfig.h"
#import <Security/Security.h>

@interface GTClientUserInitService ()

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, assign) int64_t authorizationTime;
@property (nonatomic, assign) int64_t expiresIn;
@property (nonatomic, readonly) SecKeyRef publickKey;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation GTClientUserInitService

+ (id)service {
    static GTClientUserInitService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
    });
    return service;
}

+ (BOOL)authenticated {
    return YES;
}

+ (NSString *)authorization {
    return [[GTClientUserInitService service] _authorization];
}

+ (void)authenticate {
    [[GTClientUserInitService service] _authenticate];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)_authenticate {
    NSString *key = [GTSystemConfig appKey];
    NSString *secret = [GTSystemConfig appSecret];
    if ([GTStringUtils isEmpty:key] || [GTStringUtils isEmpty:secret]) {
        return;
    }

    NSString *temp = [GTStringUtils base64:[NSString stringWithFormat:@"%@:%@", key, secret]];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", temp];

    NSURL *url = [GTSystemConfig apiUrl:AUTHORIZATION_URI];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:authorization forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[@"grant_type=client_credentials&scope=client" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:DEFAULT_HTTP_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_operationQueue
                           completionHandler:^(NSURLResponse *_Nullable response,
                                               NSData *_Nullable data,
                                               NSError *_Nullable connectionError) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               if (httpResponse.statusCode == 200 && !connectionError) {
                                   NSError *error;
                                   NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:kNilOptions
                                                                                                error:&error];
                                   if (!error) {
                                       @try {
                                           _accessToken = [dictionary objectForKey:@"access_token"];
                                           _tokenType = [dictionary objectForKey:@"token_type"];
                                           _expiresIn = [[dictionary objectForKey:@"expires_in"] longValue];
                                           _authorizationTime = [GTDateTimeUtil currentTimeMillis];
                                           _publickKey = [GTCryptoTool addPublicKey:[dictionary objectForKey:@"public_key"] tag:@"public_key"];

                                           [self sendClientUserReport];
                                       }
                                       @catch (NSException *exception) {
                                           // Ignore exception
                                       }
                                   }
                               }
                           }];
}

- (NSString *)_authorization {
    if (![GTStringUtils isEmpty:_accessToken] && ![GTStringUtils isEmpty:_tokenType]) {
        return [NSString stringWithFormat:@"%@ %@", _tokenType, _accessToken];
    }
    return @"";
}

- (void)sendClientUserReport {
    NSURL *url = [GTSystemConfig apiUrl:UPLOAD_USER_INFO_URI];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:[self _authorization] forHTTPHeaderField:@"Authorization"];

    NSData *chunk = [GTCryptoTool encryptRSA:[self userInformation] withKeyRef:_publickKey];

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[GTLoggerFactory version] forKey:@"sdkVersion"];
    [dictionary setObject:[chunk base64EncodedStringWithOptions:0] forKey:@"chunk"];

    NSError *error;
    NSData *body = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error) {
        return;
    }

    [request setHTTPBody:body];
    [request setValue:[NSString stringWithFormat:@"%zd", body.length] forHTTPHeaderField:@"Content-Length"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:DEFAULT_HTTP_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_operationQueue
                           completionHandler:^(NSURLResponse *_Nullable response,
                                               NSData *_Nullable data,
                                               NSError *_Nullable connectionError) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               if (httpResponse.statusCode == 200 && !connectionError) {
                                   // TODO
                               }
                               NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                           }];
}

- (NSData *)userInformation {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *dictionary = @{
        @"platform" : @"ios",
        @"uid" : [GTDeviceID uid],
        @"alias" : [GTSystemConfig alias],
        @"model" : [UIDevice currentDevice].model,
        @"imei" : @"",
        @"macAddress" : @"",
        @"osVersion" : [UIDevice currentDevice].systemVersion,
        @"appId" : [[NSBundle mainBundle] bundleIdentifier],
        @"version" : infoDictionary[@"CFBundleVersion"],
        @"versionString" : infoDictionary[@"CFBundleShortVersionString"]
    };

    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    if (!err) {
        return data;
    }

    return [NSData data];
}

@end
