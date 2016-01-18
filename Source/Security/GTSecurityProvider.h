//
//  GTSecurityProvider.h
//  LogLibrary
//
//  Created by Keith Ellis on 16/1/13.
//  Copyright © 2016年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GTSecurityProvider <NSObject>

- (NSData *)password;
- (NSData *)salt;

@end
