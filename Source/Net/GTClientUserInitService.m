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
#import "GTLogUtil.h"
#import "GTLoggerConstants.h"
#import "GTLoggerFactory.h"
#import "GTScheduleManager.h"
#import "GTServerConfig.h"
#import "GTStringUtils.h"
#import "GTStringUtils.h"
#import "GTSystemConfig.h"

@interface GTClientUserInitService ()

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, assign) int64_t authorizationTime;
@property (nonatomic, assign) int64_t expiresIn;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) GTServerConfig *config;

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

+ (BOOL)granted {
    GTClientUserInitService *service = [GTClientUserInitService service];
    return service.config != nil && [service _authenticated] && [service.config granted];
}

+ (BOOL)authenticated {
    return [[GTClientUserInitService service] _authenticated];
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

- (BOOL)_authenticated {
    if (![GTStringUtils isEmpty:_tokenType] && ![GTStringUtils isEmpty:_accessToken]) {
        return YES;
    }
    return NO;
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
                                       [GTLogUtil i:NSStringFromClass(self.class) msg:dictionary.description];
                                       @try {
                                           _accessToken = [dictionary objectForKey:@"access_token"];
                                           _tokenType = [dictionary objectForKey:@"token_type"];
                                           _expiresIn = [[dictionary objectForKey:@"expires_in"] longValue];
                                           _authorizationTime = [GTDateTimeUtil currentTimeMillis];
                                           [GTCryptoTool addPublicKey:[dictionary objectForKey:@"public_key"]];
                                           [GTLogUtil i:NSStringFromClass(self.class) msg:@"Client user authenticate successful!"];
                                           [self sendUserReport];
                                       }
                                       @catch (NSException *exception) {
                                           [GTLogUtil e:NSStringFromClass(self.class) msg:exception.description];
                                       }
                                   }
                               } else {
                                   if (connectionError) {
                                       [GTLogUtil e:NSStringFromClass(self.class) msg:nil err:connectionError];
                                   }
                                   if (httpResponse.statusCode == 401) {
                                       [GTLogUtil e:NSStringFromClass(self.class) msg:@"Client user authenticate failed, please check your key and secret!"];
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

- (void)sendUserReport {
    NSURL *url = [GTSystemConfig apiUrl:UPLOAD_USER_INFO_URI];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:[self _authorization] forHTTPHeaderField:@"Authorization"];

    NSData *chunk = [GTCryptoTool encryptAES:[self userInformation]];
    if (!chunk) {
        [GTLogUtil e:NSStringFromClass(self.class) msg:@"Encrypt user report information failed!"];
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[GTLoggerFactory version] forKey:@"sdkVersion"];
    [dictionary setObject:[GTCryptoTool securityString] forKey:@"signature"];
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
                                   NSError *error;
                                   NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:kNilOptions
                                                                                                error:&error];
                                   if (!error) {
                                       [GTLogUtil i:NSStringFromClass(self.class) msg:dictionary.description];
                                       [self impServerConfig:[[GTServerConfig alloc] initWithAttr:dictionary]];
                                   }
                               } else {
                                   if (connectionError) {
                                       [GTLogUtil e:NSStringFromClass(self.class) msg:nil err:connectionError];
                                   }
                                   if (httpResponse.statusCode != 200) {
                                       [GTLogUtil e:NSStringFromClass(self.class) msg:@"Upload user information report failed!"];
                                   }
                               }
                           }];
}

- (NSData *)userInformation {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *dictionary = @{
        @"platform" : @(PLATFORM_IOS),
        @"uid" : [GTDeviceID uid],
        @"alias" : [GTSystemConfig alias],
        @"model" : [UIDevice currentDevice].model,
        @"imei" : @"",
        @"macAddress" : @"",
        @"osVersion" : [UIDevice currentDevice].systemVersion,
        @"appId" : [[NSBundle mainBundle] bundleIdentifier],
        @"version" : infoDictionary[@"CFBundleVersion"],
        @"versionString" : infoDictionary[@"CFBundleShortVersionString"],
        //@"deviceId" : @"",
        @"recordOn" : @([GTLoggerFactory isOn])
    };

    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&err];
    if (!err) {
        return data;
    }

    return [NSData data];
}

- (void)impServerConfig:(GTServerConfig *)config {
    [GTLogUtil i:NSStringFromClass(self.class) msg:@"Read server config successful!"];
    if (config == nil) {
        return;
    }

    _config = config;

    if (!config.granted) {
        [GTLogUtil i:NSStringFromClass(self.class) msg:@"Client user not allow to upload log file!"];
        return;
    }

    [GTScheduleManager schedule];
    // TODO
}

@end
