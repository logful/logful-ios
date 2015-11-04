//
//  GTUploadLogFileOperation.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTUploadOperation.h"

@class GTLogFileMeta;

@interface GTUploadLogFileOperation : GTUploadOperation

+ (instancetype)create:(GTLogFileMeta *)meta;
- (void)setMsgLayoutParam:(NSString *)layoutJson;

@end
