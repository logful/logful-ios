
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

@interface GTClientAuthUtil ()

@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, assign) int64_t authorizationTime;
@property (nonatomic, assign) int64_t expiresIn;

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

+ (void)addDelegate:(id<GTClientAuthUtilDelegate>)delegate {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    [util.delegates addObject:delegate];
}

+ (void)removeDelegate:(id<GTClientAuthUtilDelegate>)delegate {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    [util.delegates removeObject:delegate];
}

+ (void)auth {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    [util checkAndRequestToken];
}

+ (void)clearToken {
    GTClientAuthUtil *util = [GTClientAuthUtil util];
    util.accessToken = nil;
    util.tokenType = nil;
    util.authorizationTime = 0;
    util.expiresIn = 0;
}

- (void)checkAndRequestToken {
    if (![GTStringUtils isEmpty:_accessToken] && ![GTStringUtils isEmpty:_tokenType]) {
        int64_t diff = ([GTDateTimeUtil currentTimeMillis] - _authorizationTime) / 1000;
        if (diff <= _expiresIn) {
            [self valid:_delegates.allObjects token:_accessToken tokenType:_tokenType];
        } else {
            [self requestToken];
        }
    } else {
        [self requestToken];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegates = [NSHashTable weakObjectsHashTable];
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

    __block NSArray *temp_ = _delegates.allObjects;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *_Nullable response,
                                               NSData *_Nullable data, NSError *_Nullable connectionError) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               if (connectionError) {
                                   [self failure:temp_];
                               } else {
                                   if (httpResponse.statusCode == 200) {
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

                                                   [self valid:temp_ token:_accessToken tokenType:_tokenType];
                                               }
                                               @catch (NSException *exception) {
                                                   [self failure:temp_];
                                               }
                                           }
                                       }
                                   } else {
                                       [self invalid:temp_];
                                   }
                               }
                           }];
}

- (void)valid:(NSArray *)delegates token:(NSString *)token tokenType:(NSString *)tokenType {
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didAuthorization:tokenType:)]) {
            [delegate didAuthorization:token tokenType:tokenType];
        }
    }
}

- (void)invalid:(NSArray *)delegates {
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didInvalid)]) {
            [delegate didInvalid];
        }
    }
}

- (void)failure:(NSArray *)delegates {
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didFailure)]) {
            [delegate didFailure];
        }
    }
}

@end
