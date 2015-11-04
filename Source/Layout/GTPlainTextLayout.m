//
//  PlainTextLayout.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/8.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTPlainTextLayout.h"
#import "GTCryptoTool.h"
#import "GTLogEvent.h"

@implementation GTPlainTextLayout

- (NSData *)data:(GTLogEvent *)logEvent {
    NSString *encryptedTag = [GTCryptoTool encrypt:[logEvent getTag]];
    NSString *encryptedMsg = [GTCryptoTool encrypt:[logEvent getMessage]];

    NSArray *values = @[ [logEvent getDateString],
                         @([logEvent getTimeMillis]),
                         encryptedTag,
                         encryptedMsg,
                         @([logEvent getLayoutId]) ];

    NSString *line = [NSString stringWithFormat:@"%@\n", [values componentsJoinedByString:@"|"]];
    return [line dataUsingEncoding:NSUTF8StringEncoding];
}

@end
