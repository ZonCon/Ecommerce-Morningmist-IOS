//
//  CheckoutTableViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 27/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "NavigationViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "AppDelegate.h"
#import "SyncViewController.h"
#import "CheckoutTableViewController.h"
#import "LoginTableViewController.h"
#import "DetectLoginTableViewController.h"
#import "ConfirmCollectionViewController.h"

@interface CheckoutTableViewController ()

@end

@implementation CheckoutTableViewController

@synthesize textAddress = _textAddress;
@synthesize textCity = _textCity;
@synthesize textCountry = _textCountry;
@synthesize textEmail = _textEmail;
@synthesize textName = _textName;
@synthesize textPhone = _textPhone;
@synthesize textPincode = _textPincode;
@synthesize textState = _textState;
@synthesize butNext = _butNext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    IS_OPENED_FROM_CART = false;
}

- (void) viewDidAppear:(BOOL)animated {
    
    
    IS_OPENED_FROM_CART = true;
    
    _textCountry.text = MY_COUNTRYNAME;
    _textState.text = MY_STATENAME;
    _textCity.text = MY_CITYNAME;
    
    self.navigationItem.title = @"Shipping";
    
    UITapGestureRecognizer *tapNextRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnNext:)];
    tapNextRecognizer.numberOfTapsRequired = 1;
    [_butNext addGestureRecognizer:tapNextRecognizer];
    _butNext.userInteractionEnabled = YES;
    
    NSDictionary *cvEmail = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                              };
    NSMutableArray *arrEmail = [[DbHelper getSharedInstance] retrieveRecords:cvEmail];
    if(arrEmail.count > 0) {
        cvEmail = [arrEmail objectAtIndex:0];
        _textEmail.text = [cvEmail objectForKey:DB_COL_EMAIL];
        
        if(_textEmail.text.length > 0) {
            if(IS_SIGNED_IN) {
                [_textEmail setEnabled:NO];
                [_textEmail setBackgroundColor:[UIColor lightGrayColor]];
            }
        } else {
            [_textEmail setEnabled:YES];
            [_textEmail setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    NSDictionary *cvName = @{
                             DB_COL_TYPE: DB_RECORD_TYPE_MY_NAME
                             };
    NSMutableArray *arrNames = [[DbHelper getSharedInstance] retrieveRecords:cvName];
    if(arrNames.count > 0) {
        cvName = [arrNames objectAtIndex:0];
        _textName.text = [cvName objectForKey:DB_COL_NAME];
    }
    
    NSDictionary *cvAddress = @{
                                DB_COL_TYPE: DB_RECORD_TYPE_MY_ADDRESS
                                };
    NSMutableArray *arrAddresses = [[DbHelper getSharedInstance] retrieveRecords:cvAddress];
    if(arrAddresses.count > 0) {
        cvAddress = [arrAddresses objectAtIndex:0];
        _textAddress.text = [cvAddress objectForKey:DB_COL_CONTENT];
    }
    
    NSDictionary *cvPhone = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_PHONE
                              };
    NSMutableArray *arrPhone = [[DbHelper getSharedInstance] retrieveRecords:cvPhone];
    if(arrPhone.count > 0) {
        cvPhone = [arrPhone objectAtIndex:0];
        _textPhone.text = [cvPhone objectForKey:DB_COL_PHONE];
    }
    
    NSDictionary *cvPincode = @{
                                DB_COL_TYPE: DB_RECORD_TYPE_MY_PINCODE
                                };
    NSMutableArray *arrPincode = [[DbHelper getSharedInstance] retrieveRecords:cvPincode];
    if(arrPincode.count > 0) {
        cvPincode = [arrPincode objectAtIndex:0];
        _textPincode.text = [cvPincode objectForKey:DB_COL_TITLE];
    }
    
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
                        but.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_ACTION_BUTTON];
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void) tappedOnNext:(UIGestureRecognizer*)gestureRecognizer; {
    
    if(_textName.text.length == 0 || _textPhone.text.length == 0 || _textPincode.text.length == 0 || _textAddress.text.length == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message: @"No fields can be blank!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        NSDictionary *cvEmail = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                                  };
        [[DbHelper getSharedInstance] deleteRecord:cvEmail];
        cvEmail = @{
                    DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL,
                    DB_COL_EMAIL: _textEmail.text
                    };
        [[DbHelper getSharedInstance] insertRecord:cvEmail];
        
        NSDictionary *cvName = @{
                                 DB_COL_TYPE: DB_RECORD_TYPE_MY_NAME
                                 };
        [[DbHelper getSharedInstance] deleteRecord:cvName];
        cvName = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_MY_NAME,
                   DB_COL_NAME: _textName.text
                   };
        [[DbHelper getSharedInstance] insertRecord:cvName];
        
        NSDictionary *cvAddress = @{
                                    DB_COL_TYPE: DB_RECORD_TYPE_MY_ADDRESS
                                    };
        [[DbHelper getSharedInstance] deleteRecord:cvAddress];
        cvAddress = @{
                      DB_COL_TYPE: DB_RECORD_TYPE_MY_ADDRESS,
                      DB_COL_CONTENT: _textAddress.text
                      };
        [[DbHelper getSharedInstance] insertRecord:cvAddress];
        
        NSDictionary *cvPhone = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_MY_PHONE
                                  };
        [[DbHelper getSharedInstance] deleteRecord:cvPhone];
        cvPhone = @{
                    DB_COL_TYPE: DB_RECORD_TYPE_MY_PHONE,
                    DB_COL_PHONE: _textPhone.text
                    };
        [[DbHelper getSharedInstance] insertRecord:cvPhone];
        
        NSDictionary *cvPincode = @{
                                    DB_COL_TYPE: DB_RECORD_TYPE_MY_PINCODE
                                    };
        [[DbHelper getSharedInstance] deleteRecord:cvPincode];
        cvPincode = @{
                      DB_COL_TYPE: DB_RECORD_TYPE_MY_PINCODE,
                      DB_COL_TITLE: _textPincode.text
                      };
        [[DbHelper getSharedInstance] insertRecord:cvPincode];
        
        if(IS_SIGNED_IN) {
            
            ConfirmCollectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmContainer"];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            
            DetectLoginTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetectLoginContainer"];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
    }
}

@end
