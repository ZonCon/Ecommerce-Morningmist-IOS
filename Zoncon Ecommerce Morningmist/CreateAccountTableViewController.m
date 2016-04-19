//
//  CreateAccountTableViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 30/12/15.
//  Copyright © 2015 MeGo Technologies. All rights reserved.
//

#import "CreateAccountTableViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "SyncViewController.h"
#import "NavigationViewController.h"

@interface CreateAccountTableViewController ()

@end

@implementation CreateAccountTableViewController

static NSMutableData *_responseData;
@synthesize textConfirmPassword = _textConfirmPassword;
@synthesize textEmail = _textEmail;
@synthesize textName = _textName;
@synthesize textPassword = _textPassword;
@synthesize connCheck = _connCheck;
@synthesize connCreate = _connCreate;
@synthesize butAvailability = _butAvailability;

Boolean isEmailValid = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textPassword.secureTextEntry = true;
    _textConfirmPassword.secureTextEntry = true;
    
    isEmailValid = false;
    self.navigationItem.title = @"NEW ACCOUNT";
    
    _textEmail.delegate = self;
    _textConfirmPassword.delegate = self;
    _textName.delegate = self;
    _textPassword.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) downSave:(id)sender {
    
    if(_textEmail.text.length == 0 || _textPassword.text.length == 0 || _textConfirmPassword.text.length == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"No fields can be left blank!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    } else {
        
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Email is invalid!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if(_textPassword.text.length < 8) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Passwords should be 8 or more characters long!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        if([_textPassword.text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Password should contain at least one number!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        if(![_textPassword.text isEqualToString:_textConfirmPassword.text]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Passwords are not equal!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        [self callCreateAccountScript];
    }
    
}

- (void) callCreateAccountScript {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_CREATE_ACCOUNT];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"password\": \"%@\"}]", PID, _textEmail.text, _textPassword.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    NSLog(@"URL=%@", urlString);
    NSLog(@"REQUEST=%@", myRequestString);
    
    _connCreate = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void) callCheckEmailScript {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_USER_APPS];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\"}]", PID, _textEmail.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    NSLog(@"URL=%@", urlString);
    NSLog(@"REQUEST=%@", myRequestString);
    
    _connCheck = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

-(IBAction) checkAvailability:(id)sender {
    
    if(_textEmail.text.length == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"No fields can be left blank!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    } else {
        
        [self callCheckEmailScript];
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(!isEmailValid) {
        
        return 2;
        
    } else {
        
        return 5;
        
    }
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]]];
    
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
    
    if(connection == _connCheck) {
        
        NSString *data = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
        NSLog(@"%@", data);
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            NSString* value = [json objectForKey:@"value"];
            NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArr = [NSJSONSerialization
                                JSONObjectWithData:jsonData //1
                                options:kNilOptions
                                error:&error];
            
            NSString *projectStr = @"";
            
            for(int i = 0; i < jsonArr.count; i++) {
                
                NSDictionary *dict = [jsonArr objectAtIndex:i];
                
                NSString *strPjName = [dict objectForKey:@"nameProject"];
                NSString *strPjId = [dict objectForKey:@"idProjects"];
                
                if([strPjId integerValue] == [PID integerValue]) {
                    
                } else {
                    
                    projectStr = [NSString stringWithFormat:@"%@ %@", projectStr, strPjName];
                    
                }
                
                
            }
            
            if(jsonArr.count > 0) {
                
                NSString *msg = [NSString stringWithFormat:@"Account for your email already exists on ZonCon App Management System. If you don't remember the password, please reset it by following the 'Forgot Password' button."];
                NSLog(@"MSG=%@", msg);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                message:msg
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                isEmailValid = true;
                [_butAvailability setTitle:@"Email is Available" forState:UIControlStateNormal];
                [_butAvailability setEnabled:FALSE];
                [_butAvailability setBackgroundColor:TEXT_COLOR];
                [_textEmail setEnabled:FALSE];
                [self.tableView reloadData];
            }
            
        } else {
            
            
            
        }
        
    } else {
        
        NSString *data = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
        NSLog(@"%@", data);
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Account created successfully! Please login now."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Account creation failure!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if(connection == _connCheck) {
        
        [self callCheckEmailScript];
        
    } else {
        
        [self callCreateAccountScript];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
