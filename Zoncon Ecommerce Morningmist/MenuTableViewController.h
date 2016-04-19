//
//  MenuTableViewController.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 02/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewController : UITableViewController <UIPageViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *labelUser;
@property (nonatomic, strong) IBOutlet UIButton *labelAccount_1;
@property (nonatomic, strong) IBOutlet UIButton *labelAccount_2;
@property (nonatomic, strong) IBOutlet UIButton *buttonMyAFX;

- (void) loadLogin;

-(IBAction) downAccount_1:(id) sender;
-(IBAction) downAccount_2:(id) sender;
-(IBAction) writeFeedbackEmail:(id) sender;
-(IBAction) shareWithFriends:(id) sender;
-(IBAction) openDevInfo:(id) sender;
-(IBAction) rateThisApp:(id) sender;
-(IBAction) openMyRecords:(id) sender;

@end
