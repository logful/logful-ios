//
//  GTLruCache.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLruCache : NSObject

- (id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;
- (NSDictionary *)values;

@property (nonatomic, assign) NSInteger countLimit;

@end
