//
//  LoginTableViewController.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 02/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import "LoginTableViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "SyncViewController.h"

@interface LoginTableViewController ()

@end

@implementation LoginTableViewController

static NSMutableData *_responseData;
@synthesize connLogin = _connLogin;

@synthesize textEmail = _textEmail;
@synthesize textPassword = _textPassword;
@synthesize fromCart = _fromCart;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textPassword.secureTextEntry = true;
    
    _textEmail.delegate = self;
    _textPassword.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

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

-(IBAction) downLogin:(id) sender
{

    
    if(_textEmail.text.length == 0 || _textPassword.text.length == 0) {
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
    
    [self callLoginDownloadScript];
    
}

- (void) callLoginDownloadScript {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_LOGIN];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"password\": \"%@\", \"idExtern\": \"\"}]", PID,  _textEmail.text, _textPassword.text];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connLogin = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    
    if(connection == _connLogin) {
        
        NSString *data = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
        NSLog(@"Data=%@", data);
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
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
                                      DB_COL_EMAIL: _textEmail.text
                                      };
            cvToken = @{
                                      DB_COL_TYPE: DB_RECORD_TYPE_MY_TOKEN,
                                      DB_COL_TITLE: token
                                      };
            
            [[DbHelper getSharedInstance] insertRecord:cvEmail];
            [[DbHelper getSharedInstance] insertRecord:cvToken];
            
            if(_fromCart) {
                
                
                NSDictionary *cvEmail = @{
                                          DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                                          };
                NSDictionary *cvToken = @{
                                          DB_COL_TYPE: DB_RECORD_TYPE_MY_TOKEN
                                          };
                
                
                NSMutableArray *arrEmail = [[DbHelper getSharedInstance] retrieveRecords:cvEmail];
                NSMutableArray *arrToken = [[DbHelper getSharedInstance] retrieveRecords:cvToken];
                
                if(arrEmail.count > 0 && arrToken.count > 0) {
                    
                    cvEmail = [arrEmail objectAtIndex:0];
                    MY_EMAIL = (NSString *)[cvEmail objectForKey:DB_COL_EMAIL];
                    
                    cvToken = [arrToken objectAtIndex:0];
                    MY_TOKEN = (NSString *)[cvToken objectForKey:DB_COL_TITLE];
                    
                    IS_SIGNED_IN = true;
                    
                } else {
                    
                    MY_EMAIL = @"";
                    MY_TOKEN = @"";
                    MY_NAME = @"";
                    
                }
                
                
            } else {
                
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                
            }
            
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Operation Failed! Credentials were invalid."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
            
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    if(connection == _connLogin) {
        
        [self callLoginDownloadScript];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
