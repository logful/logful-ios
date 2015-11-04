//
//  GTFileManager.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTFileManager : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;

- (void)write:(NSData *)data;
- (unsigned long long)available;
- (void)flush;
- (void)close;

- (void)releaseManager;

@end
