//
//  GTUploadOperation.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTUploadOperation.h"
#import "GTMultipartInputStream.h"
#import "GTLoggerConstants.h"
#import "GTClientAuthUtil.h"

#define kUploadOperatioLockName @"com.getui.log.upload.operation.lock"

typedef NS_ENUM(NSInteger, GTUploadOperationState) {
    GTUploadOperationStatePaused = -1,
    GTUploadOperationStateReady = 1,
    GTUploadOperationStateExecuting = 2,
    GTUploadOperationStateFinished = 3,
};

@interface GTUploadOperation ()

@property (nonatomic, assign) GTUploadOperationState state;
@property (nonatomic, strong, readwrite) NSRecursiveLock *lock;
@property (nonatomic, strong, nonnull) NSMutableData *responseData;

@end

@implementation GTUploadOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = GTUploadOperationStateReady;
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = kUploadOperatioLockName;
        self.responseData = [NSMutableData data];
    }
    return self;
}

- (BOOL)isPaused {
    return self.state == GTUploadOperationStatePaused;
}

- (BOOL)isReady {
    return self.state == GTUploadOperationStateReady && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == GTUploadOperationStateExecuting;
}

- (BOOL)isFinished {
    return self.state == GTUploadOperationStateFinished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    [self.lock lock];

    self.state = GTUploadOperationStateExecuting;

    if ([GTClientAuthUtil authenticated]) {
        [self startRequest:[GTClientAuthUtil accessToken] tokenType:[GTClientAuthUtil tokenType]];
    }

    [self.lock unlock];

    [self finish];
}

- (void)startRequest:(NSString *)token tokenType:(NSString *)tokenType {
    GTMultipartInputStream *body = [self bodyStream];
    NSURL *url = [self url];

    if (body == nil || self.url == nil) {
        return;
    }

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    // Setting the body of the post to the reqeust
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", [body boundary]] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long) [body length]] forHTTPHeaderField:@"Content-Length"];
    [request addValue:[NSString stringWithFormat:@"%@ %@", tokenType, token] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBodyStream:body];

    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:DEFAULT_HTTP_REQUEST_TIMEOUT];
    [request setHTTPMethod:@"POST"];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    if (connection != nil) {
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [connection start];
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]];
        } while (!self.isFinished);
    }
}

- (NSString *)identifier {
    return @"";
}

- (GTMultipartInputStream *)bodyStream {
    // Rewrite
    return nil;
}

- (NSURL *)url {
    // Rewrite
    return nil;
}

- (void)success {
    // Rewrite
}

- (void)response:(NSData *)data {
    // Rewrite
}

- (void)failure {
    // Rewrite
}

- (void)finish {
    [self.lock lock];
    self.state = GTUploadOperationStateFinished;
    [self.lock unlock];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection __unused *)connection
didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    if (httpResponse.statusCode == 200) {
        [self success];
    } else if (httpResponse.statusCode == 401) {
        [GTClientAuthUtil authenticate];
    }
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_responseData.length > 0) {
        [self response:_responseData];
    }
}

- (void)connection:(NSURLConnection __unused *)connection
  didFailWithError:(NSError *)error {
    [self failure];
    [self finish];
}

@end
