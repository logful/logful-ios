//
//  GTAttachmentFileMeta.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTAttachmentFileMeta : NSObject

@property (nonatomic, assign) int64_t id;
@property (nonatomic, copy, nonnull) NSString *filename;
@property (nonatomic, assign) int32_t sequence;
@property (nonatomic, assign) int64_t createTime;
@property (nonatomic, assign) int64_t deleteTime;
@property (nonatomic, assign) int status;
@property (nonatomic, copy, nullable) NSString *fileMD5;

+ (GTAttachmentFileMeta *__nonnull)create:(NSString *__nonnull)filename
                                 sequence:(int32_t)sequence;

@end
