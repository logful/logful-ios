//
//  AppDelegate.h
//  LogExample
//
//  Created by Keith Ellis on 15/8/5.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeTuiSdk.h"

/// 个推开发者网站中申请App时注册的AppId、AppKey、AppSecret
#define kGtAppId           @"RDQVXgdN2YAFtMFw3a9v4"
#define kGtAppKey          @"Cb6XvcFiuu5cvo6e90pr88"
#define kGtAppSecret       @"kxtY9iJwLz9NwJof1R7ya"

/// 需要使用个推回调时，需要添加"GeTuiSdkDelegate"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
