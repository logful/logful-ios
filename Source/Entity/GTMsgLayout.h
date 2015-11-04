//
//  MsgLayout.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/25.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTMsgLayout : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, copy, nonnull) NSString *layout;

+ (GTMsgLayout *__nonnull)create:(NSString *__nonnull)string;

@end
