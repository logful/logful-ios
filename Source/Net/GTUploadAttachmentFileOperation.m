//
//  GTUploadAttachmentFileOperation.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/10/16.
//  Copyright © 2015年 getui. All rights reserved.
//

#import "GTUploadAttachmentFileOperation.h"
#import "GTMultipartInputStream.h"
#import "GTLoggerConstants.h"
#import "GTSystemConfig.h"
#import "GTLogStorage.h"
#import "GTChecksum.h"
#import "GTDeviceID.h"
#import "GTLoggerFactory.h"
#import "GTAttachmentFileMeta.h"

@interface GTUploadAttachmentFileOperation ()

@property (nonatomic, strong, nonnull) GTAttachmentFileMeta *meta;

@end

@implementation GTUploadAttachmentFileOperation

+ (instancetype)create:(GTAttachmentFileMeta *)meta {
    return [[self alloc] initWithAttachmentFileMeta:meta];
}

- (instancetype)initWithAttachmentFileMeta:(GTAttachmentFileMeta *)meta {
    self = [super init];
    if (self) {
        self.meta = meta;
    }
    return self;
}

- (NSString *)identifier {
    return [NSString stringWithFormat:@"%lld-%d", self.meta.id, 4];
}

- (GTMultipartInputStream *)bodyStream {
    if (_meta == nil) {
        return nil;
    }

    NSString *inFilePath = [GTLogStorage attachmentFilePath:_meta.filename];

    // Check exist and is file.
    if (![GTLogStorage fileExistsAtPath:inFilePath]) {
        return nil;
    }

    // Calculate out gzip file md5.
    NSString *fileMD5 = [GTChecksum fileMD5:inFilePath];
    if (fileMD5 == nil) {
        return nil;
    }

    GTMultipartInputStream *body = [[GTMultipartInputStream alloc] init];
    [body addPartWithName:@"platform" string:@"ios"];
    [body addPartWithName:@"sdkVersion" string:[GTLoggerFactory version]];
    [body addPartWithName:@"uid" string:[GTDeviceID uid]];
    [body addPartWithName:@"appId" string:[[NSBundle mainBundle] bundleIdentifier]];
    [body addPartWithName:@"fileSum" string:fileMD5];
    [body addPartWithName:@"attachmentId" string:[NSString stringWithFormat:@"%d", _meta.sequence]];
    [body addPartWithName:@"attachmentFile" path:inFilePath];

    return body;
}

- (NSURL *)url {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                                           [GTSystemConfig baseUrl],
                                                           UPLOAD_ATTACHMENT_FILE_URI]];
}

- (void)success {
}

- (void)failure {
}

@end
