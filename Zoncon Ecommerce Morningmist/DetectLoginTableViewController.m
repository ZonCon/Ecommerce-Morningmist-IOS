//
//  DetectLoginTableViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 31/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "NavigationViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "AppDelegate.h"
#import "SyncViewController.h"
#import "ForgotPasswordTableViewController.h"
#import "DetectLoginTableViewController.h"
#import "ConfirmCollectionViewController.h"

@interface DetectLoginTableViewController ()

@end

@implementation DetectLoginTableViewController

static NSMutableData *_responseData;

@synthesize fieldConfirm = _fieldConfirm;
@synthesize labelConfirm = _labelConfirm;
@synthesize fieldEmail = _fieldEmail;
@synthesize labelPassword = _labelPassword;
@synthesize fieldPassword = _fieldPassword;
@synthesize connCheck = _connCheck;
@synthesize connNew = _connNew;
@synthesize connExisting = _connExisting;
@synthesize butForgot = _butForgot;
@synthesize butNext = _butNext;
@synthesize labelMessage = _labelMessage;

Boolean isCheckDone = false;
Boolean isNewCustomer = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *cvEmail = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                              };
    NSMutableArray *arrEmail = [[DbHelper getSharedInstance] retrieveRecords:cvEmail];
    if(arrEmail.count > 0) {
        cvEmail = [arrEmail objectAtIndex:0];
        _fieldEmail.text = [cvEmail objectForKey:DB_COL_EMAIL];
        
        if(_fieldEmail.text.length > 0) {
            if(IS_SIGNED_IN) {
                [_fieldEmail setEnabled:NO];
                [_fieldEmail setBackgroundColor:[UIColor lightGrayColor]];
            }
        } else {
            [_fieldEmail setEnabled:YES];
            [_fieldEmail setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    isNewCustomer = false;
    isCheckDone = false;
    
    [self callConnCheck];
    
    UITapGestureRecognizer *tapNextRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNext:)];
    tapNextRecognizer.numberOfTapsRequired = 1;
    [_butNext addGestureRecognizer:tapNextRecognizer];
    _butNext.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapForgotRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnForgot:)];
    tapForgotRecognizer.numberOfTapsRequired = 1;
    [_butForgot addGestureRecognizer:tapForgotRecognizer];
    _butForgot.userInteractionEnabled = YES;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) callConnCheck {
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_USER_APPS];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\"}]", PID, _fieldEmail.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connCheck = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
}

- (void) callConnExisting {

    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_LOGIN];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"password\": \"%@\", \"idExtern\": \"\"}]", PID,  _fieldEmail.text, _fieldPassword.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connExisting = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void) callConnNew {
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_CREATE_ACCOUNT];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"password\": \"%@\"}]", PID, _fieldEmail.text, _fieldPassword.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connNew = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]]];
    
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
                        but.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_ACTION_BUTTON];
                        
                    } else if([className isEqualToString:@"UILabel"]) {
                        
                        UILabel *lab = [arr_1 objectAtIndex:j];
                        lab.font = [UIFont systemFontOfSize:FONT_SIZE_ACTION_BUTTON];
                        
                    } else {
                        
                        UITextField *lab = [arr_1 objectAtIndex:j];
                        lab.font = [UIFont systemFontOfSize:FONT_SIZE_LIST_DESCS];
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    _labelMessage.font = [UIFont systemFontOfSize:12];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(isCheckDone) {
        
        return 1;
        
    } else {
        
        return 0;
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
            
            if(jsonArr.count > 0) {
                
                isNewCustomer = false;
                self.navigationItem.title = @"Existing Customer";
                
                _labelPassword.text = @"PASSWORD";
                
                [_labelConfirm setHidden:YES];
                [_fieldConfirm setHidden:YES];
                [_butForgot setHidden:NO];
                [_labelMessage setHidden:NO];
                
            } else {
                
                isNewCustomer = true;
                self.navigationItem.title = @"New Customer";
                
                _labelConfirm.text = @"CONFIRM PASSWORD";
                _labelPassword.text = @"CHOOSE PASSWORD";
                
                [_labelConfirm setHidden:NO];
                [_fieldConfirm setHidden:NO];
                [_butForgot setHidden:YES];
                [_labelMessage setHidden:YES];
                _butNext.text = @"CREATE ACCOUNT & PROCEED TO CONFIRM";
                
            }
            
            isCheckDone = true;
            [self.tableView reloadData];
            
        }
        
    } else if (connection == _connNew) {
        
        NSString *data = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            [self callConnExisting];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Account creation failed! Try again later."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    } else if (connection == _connExisting) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            IS_SIGNED_IN = true;
            
            NSString* value = [json objectForKey:@"value"];
            NSData *dataValue = [value dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization
                    JSONObjectWithData:dataValue //1
                    options:kNilOptions
                    error:&error];
            
            NSString *token = (NSString *)[json objectForKey:@"token"];
            
            NSDictionary *cvEmail = @{
                                      DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                                      };
            NSDictionary *cvToken = @{
                                      DB_COL_TYPE: DB_RECORD_TYPE_MY_TOKEN
                                      };
            [[DbHelper getSharedInstance] deleteRecord:cvEmail];
            [[DbHelper getSharedInstance] deleteRecord:cvToken];
            
            cvEmail = @{
                        DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL,
                        DB_COL_EMAIL: _fieldEmail.text
                        };
            cvToken = @{
                        DB_COL_TYPE: DB_RECORD_TYPE_MY_TOKEN,
                        DB_COL_TITLE: token
                        };
            
            [[DbHelper getSharedInstance] insertRecord:cvEmail];
            [[DbHelper getSharedInstance] insertRecord:cvToken];
            
            MY_EMAIL = _fieldEmail.text;
            MY_TOKEN = token;
            
            ConfirmCollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmContainer"];
            [self.navigationController pushViewController:vc animated:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Sign in Successful!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Sign in failed!"
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
        
        [self callConnCheck];
        
    } else if(connection == _connExisting) {
        
        [self callConnExisting];
        
    } else {
        
        [self callConnNew];
        
    }
}

- (void)userTappedOnForgot:(UIGestureRecognizer*)gestureRecognizer {
    
    ForgotPasswordTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotContainer"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)userTappedOnNext:(UIGestureRecognizer*)gestureRecognizer {
    
    if(isNewCustomer) {
        
        if(_fieldEmail.text.length == 0 || _fieldPassword.text.length == 0 || _fieldConfirm.text.length == 0) {
            
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
        
        if(![emailTest evaluateWithObject:_fieldEmail.text]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Email is invalid!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        if(_fieldPassword.text.length < 8) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Passwords should be 8 or more characters long!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        if([_fieldPassword.text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Password should contain at least one number!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        if(![_fieldPassword.text isEqualToString:_fieldConfirm.text]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Passwords are not equal!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        [self callConnNew];
        
    } else {
        
        if(_fieldEmail.text.length == 0 || _fieldPassword.text.length == 0) {
            
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
        
        if(![emailTest evaluateWithObject:_fieldEmail.text]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Email is invalid!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        if(_fieldPassword.text.length < 8) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Passwords should be 8 or more characters long!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        if([_fieldPassword.text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Password should contain at least one number!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
            
        }
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_LOGIN];
        NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"password\": \"%@\", \"idExtern\": \"\"}]", PID,  _fieldEmail.text, _fieldPassword.text];
        NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
        [ request setHTTPMethod: @"POST" ];
        [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [ request setHTTPBody: myRequestData ];
        
        _connExisting = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
    }
    
}

@end
