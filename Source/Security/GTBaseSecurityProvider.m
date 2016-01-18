//
//  GTBaseSecurityProvider.m
//  LogLibrary
//
//  Created by Keith Ellis on 16/1/13.
//  Copyright © 2016年 getui. All rights reserved.
//

#import "GTBaseSecurityProvider.h"
#import "GTDeviceID.h"
#import "GTSystemConfig.h"

@interface GTBaseSecurityProvider ()

@property (nonatomic, strong) NSData *password;
@property (nonatomic, strong) NSData *salt;

@end

@implementation GTBaseSecurityProvider

- (NSData *)password {
    if (!_password) {
        _password = [[GTSystemConfig appKey] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return _password;
}

- (NSData *)salt {
    if (!_salt) {
        _salt = [[GTDeviceID uid] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return _salt;
}

@end
