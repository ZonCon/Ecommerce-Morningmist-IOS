//
//  CreateAccountTableViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 30/12/15.
//  Copyright © 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateAccountTableViewController : UITableViewController <NSURLConnectionDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textPassword;
@property (nonatomic, strong) IBOutlet UITextField *textConfirmPassword;
@property (nonatomic, strong) IBOutlet UITextField *textName;
@property (nonatomic, strong) IBOutlet UITextField *textEmail;
@property (nonatomic, strong) IBOutlet UIButton *butAvailability;
@property (nonatomic, strong) NSURLConnection *connCheck;
@property (nonatomic, strong) NSURLConnection *connCreate;
-(IBAction) downSave:(id) sender;
-(IBAction) checkAvailability:(id) sender;

@end
