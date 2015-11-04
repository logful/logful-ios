//
//  ViewController.h
//  LogExample
//
//  Created by Keith Ellis on 15/8/5.
//  Copyright (c) 2015年 getui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *logSwitch;

- (IBAction)verbose:(id)sender;
- (IBAction)debug:(id)sender;
- (IBAction)info:(id)sender;
- (IBAction)warn:(id)sender;
- (IBAction)error:(id)sender;
- (IBAction)exception:(id)sender;
- (IBAction)fatal:(id)sender;
- (IBAction)batch:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)crash:(id)sender;
- (IBAction)interrput:(id)sender;
- (IBAction)changeStatus:(id)sender;
- (IBAction)captureScreen:(id)sender;

@end

