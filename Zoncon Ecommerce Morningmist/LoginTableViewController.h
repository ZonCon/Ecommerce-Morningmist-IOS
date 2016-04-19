//
//  LoginTableViewController.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 02/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableViewController : UITableViewController <NSURLConnectionDelegate, UITextFieldDelegate>

@property (nonatomic) Boolean fromCart;
@property (nonatomic, strong) IBOutlet UITextField *textEmail;
@property (nonatomic, strong) IBOutlet UITextField *textPassword;
@property (nonatomic, strong) NSURLConnection *connLogin;
-(IBAction) downLogin:(id) sender;

@end
