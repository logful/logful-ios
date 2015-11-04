//
//  GTAttachmentFileMeta.h 
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTAttachmentFileMeta.h"
#import "GTLoggerConstants.h"
#import "GTDateTimeUtil.h"

@implementation GTAttachmentFileMeta

- (instancetype)init {
    self = [super init];
    if (self) {
        self.id = -1;
        self.status = FILE_STATE_NORMAL;
        self.createTime = [GTDateTimeUtil currentTimeMillis];
    }
    return self;
}

+ (GTAttachmentFileMeta *)create:(NSString *)filename sequence:(int32_t)sequence {
    GTAttachmentFileMeta *meta = [[GTAttachmentFileMeta alloc] init];
    meta.filename = filename;
    meta.sequence = sequence;
    return meta;
}

@end
