//
//  GTCaptureTool.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GTLogger;

@interface GTCaptureTool : NSObject

+ (void)captureThenLog:(GTLogger *)logger
                 level:(int)level
                   tag:(NSString *)tag
                   msg:(NSString *)msg;

@end
