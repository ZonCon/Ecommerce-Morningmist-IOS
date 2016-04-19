//
//  ForgotPasswordTableViewController.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 02/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import "ForgotPasswordTableViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "SyncViewController.h"
#import "NavigationViewController.h"

@interface ForgotPasswordTableViewController ()

@end

@implementation ForgotPasswordTableViewController

static NSMutableData *_responseData;
@synthesize textEmail = _textEmail;
@synthesize connForgot = _connForgot;

- (void)viewDidLoad {
    [super viewDidLoad];
    _textEmail.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    IS_OPENED_FROM_FORGOT = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    IS_OPENED_FROM_FORGOT = false;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *arr = [cell subviews];
    NSLog(@"Class = %d", arr.count);
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


-(IBAction) downForgot:(id) sender
{
    
    if(_textEmail.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"No fields can be left blank!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];

    if(![emailTest evaluateWithObject:_textEmail.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Email is invalid!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self callForgotPasswordScript];
    
}

- (void) callForgotPasswordScript {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_RESET_PASSWORD];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\"}]", PID,  _textEmail.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    //NSLog(@"here");
    
    _connForgot = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    if(connection == _connForgot) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];

        if([result isEqualToString:@"success"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Password reset link is sent to your registered email address."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Operation Failed! Email Address does not exist."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
        //NSLog(@"%@", error.description);
    if(connection == _connForgot) {
        
        [self callForgotPasswordScript];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
