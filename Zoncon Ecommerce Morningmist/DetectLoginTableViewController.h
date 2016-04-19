//
//  DetectLoginTableViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 31/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetectLoginTableViewController : UITableViewController <NSURLConnectionDelegate>

@property (nonatomic, strong) IBOutlet UITextField *fieldEmail;
@property (nonatomic, strong) IBOutlet UITextField *fieldPassword;
@property (nonatomic, strong) IBOutlet UILabel *labelPassword;
@property (nonatomic, strong) IBOutlet UITextField *fieldConfirm;
@property (nonatomic, strong) IBOutlet UILabel *labelConfirm;
@property (nonatomic, strong) IBOutlet UILabel *butNext;
@property (nonatomic, strong) IBOutlet UILabel *butForgot;
@property (nonatomic, strong) IBOutlet UILabel *labelMessage;

@property (nonatomic, strong) NSURLConnection *connCheck;
@property (nonatomic, strong) NSURLConnection *connNew;
@property (nonatomic, strong) NSURLConnection *connExisting;

@end
