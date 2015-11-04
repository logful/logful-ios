//
//  GTLruCache.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTLruCache.h"
#import "GTMutableDictionary.h"

@interface GTLruCache () <NSCacheDelegate>

@property (nonatomic, strong, nonnull) NSCache *cache;
@property (nonatomic, strong, nonnull) GTMutableDictionary *dictionary;

@end

@implementation GTLruCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
        self.cache.delegate = self;
        self.dictionary = [[GTMutableDictionary alloc] init];
    }
    return self;
}

- (id)objectForKey:(id)key {
    return [_cache objectForKey:key];
}

- (void)setObject:(id)obj forKey:(id)key {
    if (obj != nil && key != nil) {
        [_cache setObject:obj forKey:key];
        [_dictionary setObject:obj forKey:key];
    }
}

- (void)removeObjectForKey:(id)key {
    if (key != nil) {
        [_cache removeObjectForKey:key];
        [_dictionary removeObjectForKey:key];
    }
}

- (void)removeAllObjects {
    [_cache removeAllObjects];
    [_dictionary removeAllObjects];
}

- (NSDictionary *)values {
    return [NSDictionary dictionaryWithDictionary:_dictionary];
}

- (void)setCountLimit:(NSInteger)countLimit {
    _cache.countLimit = countLimit;
}

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSArray *keys = [_dictionary allKeysForObject:obj];
    for (id key in keys) {
        [_dictionary removeObjectForKey:key];
    }
}

@end
