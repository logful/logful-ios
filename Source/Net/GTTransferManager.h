//
//  TransferManager.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/1.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTTransferManager : NSObject

+ (void)uploadLogFile;
+ (void)uploadLogFile:(uint64_t)startTime endTime:(uint64_t)endTime;

+ (void)uploadCrashReport;

+ (void)uploadAttachment;

@end
