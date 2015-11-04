//
//  GTUploadOperation.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTMultipartInputStream;

@interface GTUploadOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (NSString *)identifier;
- (GTMultipartInputStream *)bodyStream;
- (NSURL *)url;
- (void)success;
- (void)response:(NSData *)data;
- (void)failure;

@end
