//
//  GTReportSender.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/8.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTCrashReportData;

@interface GTReportSender : NSObject

- (void)send:(GTCrashReportData *)reportData;

@end
