
//
//  GTClientAuthUtil.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/29.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTClientAuthUtil.h"
#import "GTStringUtils.h"
#import "GTDateTimeUtil.h"
#import "GTLoggerConstants.h"
#import "GTSystemConfig.h"
#import "GTLoggerConstants.h"
#import "GTRemoteConfig.h"

@interface GTClientAuthUtil ()

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, assign) int64_t authorizationTime;
@property (nonatomic, assign) int64_t expiresIn;
@property (nonatomic, assign) BOOL authorizing;
@property (nonatomic, assign) BOOL initialized;

@end

@implementation GTClientAuthUtil

+ (instancetype)util {
    static GTClientAuthUtil *util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[self alloc] init];
    });
    return util;
}

+ (BOOL)authenticated {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    if (![GTStringUtils isEmpty:util.accessToken] && ![GTStringUtils isEmpty:util.tokenType]) {
        int64_t diff = ([GTDateTimeUtil currentTimeMillis] - util.authorizationTime) / 1000;
        if (diff <= util.expiresIn) {
            return YES;
        }
    }
    return NO;
}

+ (NSString *)accessToken {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    if ([GTStringUtils isEmpty:util.accessToken]) {
        return @"";
    }
    return util.accessToken;
}

+ (NSString *)tokenType {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    if ([GTStringUtils isEmpty:util.tokenType]) {
        return @"";
    }
    return util.tokenType;
}

+ (void)authenticate {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    if (!util.authorizing) {
        util.accessToken = nil;
        util.tokenType = nil;
        util.expiresIn = 0;
        util.authorizing = YES;
        [util requestToken];
    }
}

+ (void)auth {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    if (!util.authorizing) {
        util.accessToken = nil;
        util.tokenType = nil;
        util.expiresIn = 0;
        util.authorizing = YES;
        [util requestToken];
    }
}

+ (void)clearToken {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    util.accessToken = nil;
    util.tokenType = nil;
    util.authorizationTime = 0;
    util.expiresIn = 0;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.initialized = NO;
        self.authorizing = NO;
    }
    return self;
}

- (void)requestToken {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                                 [GTSystemConfig baseUrl],
                                                                 CLIENT_AUTH_URI]];
    NSString *temp = [GTStringUtils base64:[NSString stringWithFormat:@"%@:%@", APP_KEY, APP_SECRET]];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", temp];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:authorization forHTTPHeaderField:@"Authorization"];

    [request setHTTPBody:[@"grant_type=client_credentials&scope=client" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:DEFAULT_HTTP_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *_Nullable response,
                                               NSData *_Nullable data, NSError *_Nullable connectionError) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               if (httpResponse.statusCode == 200 && !connectionError) {
                                   if (data.length > 0) {
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
                                               if (!_initialized) {
                                                   [GTRemoteConfig read];
                                                   _initialized = YES;
                                               }
                                           }
                                           @catch (NSException *exception) {
                                               // Ignore exception
                                           }
                                       }
                                   }
                               }
                               _authorizing = NO;
                           }];
}

@end
