//
//  GTClientAuthUtil.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/29.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GTClientAuthUtilDelegate <NSObject>

- (void)didAuthorization:(NSString *)token tokenType:(NSString *)tokenType;

@optional
- (void)didInvalid;

@optional
- (void)didFailure;

@end

@interface GTClientAuthUtil : NSObject

+ (void)addDelegate:(id<GTClientAuthUtilDelegate>)delegate;
+ (void)removeDelegate:(id<GTClientAuthUtilDelegate>)delegate;
+ (void)auth;
+ (void)clearToken;

@end
