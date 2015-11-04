//
//  Layout.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/8.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLogEvent;

@interface GTLayout : NSObject

- (NSData *)data:(GTLogEvent *)logEvent;

@end
