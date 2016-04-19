//
//  MenuTableViewController.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 02/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import "MenuTableViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "NavigationViewController.h"
#import "SyncViewController.h"
#import "LoginTableViewController.h"
#import "ForgotPasswordTableViewController.h"
#import "ResetTableViewController.h"
#import "OrdersListCollectionViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

@synthesize labelAccount_1 = _labelAccount_1;
@synthesize labelAccount_2 = _labelAccount_2;
@synthesize labelUser = _labelUser;
@synthesize buttonMyAFX = _buttonMyAFX;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(IS_SIGNED_IN) {
        _labelUser.text = MY_EMAIL;
        [_labelAccount_1 setTitle:@"Log Out" forState:UIControlStateNormal];
        [_labelAccount_2 setTitle:@"Reset Password" forState:UIControlStateNormal];
    } else {
        _labelUser.text = @"Guest";
        [_labelAccount_1 setTitle:@"Log In" forState:UIControlStateNormal];
        [_labelAccount_2 setTitle:@"Forgot Password" forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arr = [cell subviews];
    if(arr.count > 0) {
        
        for(int i = 0; i < arr.count; i++) {
            
            NSString *stringName =  NSStringFromClass([[arr objectAtIndex:i] class]);
            if([stringName isEqualToString:@"UITableViewCellContentView"]) {
                
                NSArray *arr_1 = [[arr objectAtIndex:i] subviews];
                
                for(int j = 0; j < arr_1.count; j++) {
                    
                    NSString *className =  NSStringFromClass([[arr_1 objectAtIndex:j] class]);
                    
                    if([className isEqualToString:@"UIButton"]) {
                        
                        UIButton *but = [arr_1 objectAtIndex:j];
                        but.titleLabel.font = [UIFont fontWithName:@"Melbourne" size:FONT_SIZE_LIST_TITLES];
                        
                    } else {
                        
                        UILabel *lab = [arr_1 objectAtIndex:j];
                        lab.font = [UIFont fontWithName:@"Melbourne" size:FONT_SIZE_LIST_TITLES];
                        
                    }
                    
                    NSLog(@"Class = %@", [[arr_1 objectAtIndex:j] class]);
                    
                }
                
            }
            
        }
        
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
     if(IS_SIGNED_IN) {
         return 4;
     } else {
         return 3;
     }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0) {
        return 1;
    } else if(section == 1) {
        return 2;
    } else if(section == 3) {
        
        if(IS_SIGNED_IN) {
                return 1;
        } else {
                return 0;
        }
        
    } else {
        return 7;
    }
}

-(IBAction) downAccount_1:(id) sender {
    
    if(IS_SIGNED_IN) {
        
        UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle: @"Confirm Log Out" message: @"Do u really want to log out?" delegate: self cancelButtonTitle: @"YES"  otherButtonTitles:@"NO",nil];
        [logoutAlert show];
        
    } else {
        
        LoginTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginContainer"];
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    
}

- (void) loadLogin {
    
    LoginTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginContainer"];
    [self.navigationController pushViewController:controller animated:YES];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex==0)
    {
        
        NavigationViewController *tab = (NavigationViewController *)self.navigationController;
        [tab logout];
        [self.navigationController popViewControllerAnimated:YES];
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
    }
    
}

-(IBAction) downAccount_2:(id) sender {
    
    if(IS_SIGNED_IN) {
       
        ResetTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordContainer"];
        [self.navigationController pushViewController:controller animated:YES];
        
    } else {
        
        ForgotPasswordTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotContainer"];
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    
}

-(IBAction) writeFeedbackEmail:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        // Show the composer
        
        NSArray *usersTo = [NSArray arrayWithObjects: FEEDBACK_EMAIL_ABS, FEEDBACK_EMAIL_MEGO, nil];
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:usersTo];
        [controller setSubject:FEEDBACK_EMAIL_SUBJECT];
        [controller setMessageBody:@"Type your message here..." isHTML:NO];
        if (controller) [self presentModalViewController:controller animated:YES];
        
    } else {
        // Handle the error
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent || result == MFMailComposeResultCancelled || result == MFMailComposeResultFailed) {
    }
    [self dismissModalViewControllerAnimated:YES];

}

-(IBAction) openDevInfo:(id)sender {
    
}

-(IBAction) shareWithFriends:(id)sender {
 
    IS_OPENED_FROM_MENU = true;
    NSString *sharedMsg=SHARE_MSG;
    NSArray* sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

-(IBAction) rateThisApp:(id) sender {
    
    IS_OPENED_FROM_MENU = true;
    NSString *url = [NSString stringWithFormat:@"http://%@", APPSTORE_LINK];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
    
}

-(IBAction) openMyRecords:(id) sender {
    
    OrdersListCollectionViewController * vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"OrdersListContainer"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
