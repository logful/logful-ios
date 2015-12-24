//
//  GTLogUtil.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/12/24.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLogUtil : NSObject

+ (void)d:(NSString *)tag msg:(NSString *)msg;
+ (void)d:(NSString *)tag msg:(NSString *)msg err:(NSError *)err;

+ (void)i:(NSString *)tag msg:(NSString *)msg;
+ (void)i:(NSString *)tag msg:(NSString *)msg err:(NSError *)err;

+ (void)v:(NSString *)tag msg:(NSString *)msg;
+ (void)v:(NSString *)tag msg:(NSString *)msg err:(NSError *)err;

+ (void)w:(NSString *)tag msg:(NSString *)msg;
+ (void)w:(NSString *)tag err:(NSError *)err;
+ (void)w:(NSString *)tag msg:(NSString *)msg err:(NSError *)err;

+ (void)e:(NSString *)tag msg:(NSString *)msg;
+ (void)e:(NSString *)tag msg:(NSString *)msg err:(NSError *)err;

+ (void)f:(NSString *)tag msg:(NSString *)msg;
+ (void)f:(NSString *)tag err:(NSError *)err;
+ (void)f:(NSString *)tag msg:(NSString *)msg err:(NSError *)err;

@end
