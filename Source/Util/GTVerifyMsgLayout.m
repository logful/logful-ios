//
//  GTVerifyMsgLayout.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/28.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTVerifyMsgLayout.h"

@implementation GTVerifyMsgLayout

+ (void)verify:(NSString *)templateString {
    if (templateString == nil || templateString.length == 0) {
        return;
    }
    if ([templateString rangeOfString:@"|"].location != NSNotFound) {
        NSArray *fields = [templateString componentsSeparatedByString:@"|"];
        for (NSString *field in fields) {
            [self verifyAttributes:field];
        }
    } else {
        [self verifyAttributes:templateString];
    }
}

+ (void)verifyAttributes:(NSString *)attributeString {
    NSArray *attributes = [attributeString componentsSeparatedByString:@","];
    if (attributes.count != 3) {
        [NSException raise:@"MsgLayoutIncorrectException" format:@"Must have three part"];
    }
    NSString *part1 = attributes[0];
    NSString *part2 = attributes[1];
    NSString *part3 = attributes[2];
    if (part1.length == 0 || part2.length == 0) {
        [NSException raise:@"MsgLayoutIncorrectException" format:@"Must set a abbr and a full name"];
    }

    BOOL stringCheck = [part3 rangeOfString:@"%s" options:NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL numberCheck = [part3 rangeOfString:@"%n" options:NSCaseInsensitiveSearch].location != NSNotFound;

    if (!stringCheck && !numberCheck) {
        [NSException raise:@"MsgLayoutIncorrectException" format:@"Must set a type"];
    }
}

@end
