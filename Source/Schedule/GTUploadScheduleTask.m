//
//  GTUploadScheduleTask.m
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import "GTUploadScheduleTask.h"
#import "GTTransferManager.h"

@implementation GTUploadScheduleTask

- (void)execute {
    [GTTransferManager uploadLogFile];
    [GTTransferManager uploadAttachment];
}

@end
