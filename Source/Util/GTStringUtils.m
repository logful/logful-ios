//
//  StringUtils.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/27.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTStringUtils.h"

@implementation GTStringUtils

+ (BOOL)isEmpty:(NSString *)string {
    if (string == nil || string.length == 0) {
        return YES;
    }
    return NO;
}

+ (NSString *)propertiesDictionaryToString:(NSDictionary *)dictionary {
    __block NSMutableString *string = [[NSMutableString alloc] init];
    __block NSInteger index = 0;
    NSInteger count = dictionary.count;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
            if (index == count - 1) {
                [string appendString:[NSString stringWithFormat:@"%@=%@", key, obj]];
            } else {
                [string appendString:[NSString stringWithFormat:@"%@=%@\n", key, obj]];
            }
            index++;
        }
    }];
    return string;
}

+ (NSString *)base64:(NSString *)string {
    return [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

+ (NSData *)convertToData:(NSDictionary *)dic {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
    if (!err) {
        return data;
    }
    return nil;
}

+ (NSString *)convertToString:(NSDictionary *)dic {
    NSData *data = [self convertToData:dic];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

@end
