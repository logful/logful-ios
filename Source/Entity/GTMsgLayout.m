//
//  MsgLayout.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/25.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTMsgLayout.h"

@implementation GTMsgLayout

+ (GTMsgLayout *)create:(NSString *)string {
    GTMsgLayout *layout = [[GTMsgLayout alloc] init];
    layout.layout = string;
    return layout;
}

@end
