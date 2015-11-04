//
//  GGMutableDictionary.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/4.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTMutableDictionary.h"

@implementation GTMutableDictionary {
    dispatch_queue_t isolationQueue_;
    NSMutableDictionary *storage_;
}

- (instancetype)initCommon {
    self = [super init];
    if (self) {
        isolationQueue_ = dispatch_queue_create("com.getui.log.dictionary", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)init {
    self = [self initCommon];
    if (self) {
        storage_ = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [self initCommon];
    if (self) {
        storage_ = [NSMutableDictionary dictionaryWithCapacity:numItems];
    }
    return self;
}

- (NSDictionary *)initWithContentsOfFile:(NSString *)path {
    self = [self initCommon];
    if (self) {
        storage_ = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self initCommon];
    if (self) {
        storage_ = [[NSMutableDictionary alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (instancetype)initWithObjects:(const id[])objects forKeys:(const id<NSCopying>[])keys count:(NSUInteger)cnt {
    self = [self initCommon];
    if (self) {
        if (!objects || !keys) {
            [NSException raise:NSInvalidArgumentException format:@"objects and keys cannot be nil"];
        } else {
            for (NSUInteger i = 0; i < cnt; ++i) {
                storage_[keys[i]] = objects[i];
            }
        }
    }
    return self;
}

- (NSUInteger)count {
    __block NSUInteger count;
    dispatch_sync(isolationQueue_, ^{
        count = storage_.count;
    });
    return count;
}

- (id)objectForKey:(id)aKey {
    __block id obj;
    dispatch_sync(isolationQueue_, ^{
        obj = storage_[aKey];
    });
    return obj;
}

- (NSEnumerator *)keyEnumerator {
    __block NSEnumerator *enu;
    dispatch_sync(isolationQueue_, ^{
        enu = [storage_ keyEnumerator];
    });
    return enu;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    aKey = [aKey copyWithZone:NULL];
    dispatch_barrier_async(isolationQueue_, ^{
        storage_[aKey] = anObject;
    });
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_barrier_async(isolationQueue_, ^{
        [storage_ removeObjectForKey:aKey];
    });
}

- (void)removeAllObjects {
    dispatch_barrier_async(isolationQueue_, ^{
        [storage_ removeAllObjects];
    });
}

@end