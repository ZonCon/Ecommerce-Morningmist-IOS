//
//  ForgotPasswordTableViewController.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 02/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordTableViewController : UITableViewController <NSURLConnectionDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textEmail;
@property (nonatomic, strong) NSURLConnection *connForgot;
-(IBAction) downForgot:(id) sender;

@end
