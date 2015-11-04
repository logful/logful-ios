//
//  GTUploadSystemInfoOperation.h
//  LogLibrary
//
//  Created by Keith Ellis on 15/9/2.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTUploadOperation.h"

@protocol GTUploadSystemInfoOperationDelegate <NSObject>

- (void)didResponse:(NSData *)data;
- (void)didFailure;

@end

@interface GTUploadSystemInfoOperation : GTUploadOperation

@property (nonatomic, weak) id<GTUploadSystemInfoOperationDelegate> operationDelegate;

@end
