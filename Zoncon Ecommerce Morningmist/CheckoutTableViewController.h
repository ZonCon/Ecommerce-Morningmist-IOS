//
//  CheckoutTableViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 27/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckoutTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UILabel *textCity;
@property (nonatomic, strong) IBOutlet UILabel *textState;
@property (nonatomic, strong) IBOutlet UILabel *textCountry;
@property (nonatomic, strong) IBOutlet UITextField *textEmail;
@property (nonatomic, strong) IBOutlet UITextField *textPhone;
@property (nonatomic, strong) IBOutlet UITextField *textName;
@property (nonatomic, strong) IBOutlet UITextField *textAddress;
@property (nonatomic, strong) IBOutlet UITextField *textPincode;
@property (nonatomic, strong) IBOutlet UIButton *butNext;

@end
