//
//  GTUploadAttachmentFileOperation.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTUploadOperation.h"

@class GTAttachmentFileMeta;

@interface GTUploadAttachmentFileOperation : GTUploadOperation

+ (instancetype)create:(GTAttachmentFileMeta *)meta;

@end
