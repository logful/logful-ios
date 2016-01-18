//
//  AppDelegate.h
//  LogExample
//
//  Created by Keith Ellis on 15/8/5.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeTuiSdk.h"

#define kGtAppId           @"NXsD3hcKyl7orMs78ma5K6"
#define kGtAppKey          @"4Zh4PgmqaS61nLI7wBGz04"
#define kGtAppSecret       @"yecD1E5kMEAAdmOlBRHpq7"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

