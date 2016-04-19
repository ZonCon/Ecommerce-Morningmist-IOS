//
//  ResetTableViewController.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 05/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetTableViewController : UITableViewController <NSURLConnectionDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textOldPassword;
@property (nonatomic, strong) IBOutlet UITextField *textNewPassword;
@property (nonatomic, strong) IBOutlet UITextField *textConfirmPassword;
@property (nonatomic, strong) NSURLConnection *connForgot;
-(IBAction) downSave:(id) sender;

@end
