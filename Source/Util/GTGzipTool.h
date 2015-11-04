//
//  GzipTool.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/8/31.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTGzipTool : NSObject

+ (BOOL)compress:(NSString *)inFilePath
     outFilePath:(NSString *)outFilePath
           error:(NSError *__autoreleasing*)error;

@end
