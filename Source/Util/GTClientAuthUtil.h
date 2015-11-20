//
//  GTClientAuthUtil.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/29.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTClientAuthUtil : NSObject

+ (BOOL)authenticated;
+ (NSString *)accessToken;
+ (NSString *)tokenType;

+ (void)authenticate;

@end
