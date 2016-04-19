//
//  ResetTableViewController.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 05/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import "ResetTableViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "SyncViewController.h"
#import "NavigationViewController.h"


@interface ResetTableViewController ()

@end

@implementation ResetTableViewController

static NSMutableData *_responseData;
@synthesize connForgot = _connForgot;
@synthesize textNewPassword = _textNewPassword;
@synthesize textOldPassword = _textOldPassword;
@synthesize textConfirmPassword = _textConfirmPassword;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"RESET PASSWORD";
    
    _textOldPassword.secureTextEntry = true;
    _textOldPassword.delegate = self;
    _textNewPassword.secureTextEntry = true;
    _textNewPassword.delegate = self;
    _textConfirmPassword.secureTextEntry = true;
    _textConfirmPassword.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    IS_OPENED_FROM_RESET = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    IS_OPENED_FROM_RESET = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) downSave:(id) sender {
    
    
    if(_textOldPassword.text.length == 0 || _textNewPassword.text.length == 0 || _textConfirmPassword.text.length == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"No fields can be left blank!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    if(![_textNewPassword.text isEqualToString:_textConfirmPassword.text]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"New Password and Confirm Password should be identical!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    
    if([[_textNewPassword.text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""]) {
        
        [self.view endEditing:YES];
        
        [self callResetPasswordScript];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"New Password should be alphanumeric!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    
    
}

- (void) callResetPasswordScript {
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_FORGOT_CHANGE_PASSWORD];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"token\": \"%@\", \"oldpassword\": \"%@\", \"newpassword\": \"%@\"}]", PID, MY_EMAIL, MY_TOKEN, _textOldPassword.text, _textNewPassword.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connForgot = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


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
                        but.titleLabel.font = [UIFont fontWithName:@"Melbourne" size:FONT_SIZE_ACTION_BUTTON];
                        
                    } else {
                        
                        UILabel *lab = [arr_1 objectAtIndex:j];
                        lab.font = [UIFont fontWithName:@"Melbourne" size:FONT_SIZE_LIST_DESCS];
                        
                    }
                    
                    NSLog(@"Class = %@", [[arr_1 objectAtIndex:j] class]);
                    
                }
                
            }
            
        }
        
    }
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if(connection == _connForgot) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Password has been changed successfully! Please login again!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            NavigationViewController *tab = (NavigationViewController *)self.navigationController;
            [tab logout];
            [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Operation Failed!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if(connection == _connForgot) {
        
        [self callResetPasswordScript];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
