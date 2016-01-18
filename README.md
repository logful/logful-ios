# Logful

[![Build Status](https://travis-ci.org/logful/logful-ios.svg?branch=master)](https://travis-ci.org/logful/logful-ios)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/logful/logful-ios/blob/master/LICENSE)

Logful remote logging sdk for iOS

## Dependency

```
pod 'Logful', '~> 0.3.0'
```

## Usage

### Initialize logful iOS sdk

``` objc
#import "AppDelegate.h"
#import <Logful/Logful.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GTLoggerFactory init];
    return YES;
}
```

### Log message use logful iOS sdk

``` objc
// Use default logger
GLOG_DEBUG(@"TAG", @"debug message");

// Use custom logger
GTLogger *logger = [GTLoggerFactory logger:@"sample"];
[logger verbose:@"TAG" msg:@"verbose message"];
```

### Log message with screenshot use logful iOS sdk

``` objc
// Use default logger
GLOG_DEBUG_CAPTURE(@"TAG", @"debug message");

// Use custom logger
GTLogger *logger = [GTLoggerFactory logger:@"sample"];
[logger verbose:@"TAG" msg:@"verbose message" capture:YES];

```

## License
The MIT License (MIT)

Copyright (c) 2015-2016 Zhejiang Meiri Hudong Network Technology Co. Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
