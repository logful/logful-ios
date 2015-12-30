//
//  GTClientUserAuthService.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/12/17.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTClientUserInitService : NSObject

+ (BOOL)granted;
+ (BOOL)authenticated;
+ (NSString *)authorization;

+ (void)authenticate;

@end
