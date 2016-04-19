//
//  SelectBranchTableViewController.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 22/11/15.
//  Copyright © 2015 MeGo Technologies. All rights reserved.
//

#import "SelectLocationController.h"
#import "globals.h"
#import "DbHelper.h"
#import "SyncViewController.h"

@interface SelectLocationController ()

@end

@implementation SelectLocationController

NSMutableArray *arrCountries;
NSMutableArray *arrIdCountries;
NSMutableArray *arrStates;
NSMutableArray *arrIdStates;
NSMutableArray *arrCities;
NSMutableArray *arrIdCities;

@synthesize fromStart = _fromStart;
@synthesize pickerSelectCity = _pickerSelectCity;
@synthesize pickerSelectState = _pickerSelectState;
@synthesize pickerSelectCountry = _pickerSelectCountry;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pickerSelectCity.dataSource = self;
    _pickerSelectCity.delegate = self;
    
    _pickerSelectState.dataSource = self;
    _pickerSelectState.delegate = self;
    
    _pickerSelectCountry.dataSource = self;
    _pickerSelectCountry.delegate = self;
    
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\"}]", PID];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_COUNTRIES];
    NSLog(@"URL=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if(error == nil) {
             
             NSError* error;
             NSDictionary* json = [NSJSONSerialization
                                   JSONObjectWithData:data //1
                                   
                                   options:kNilOptions
                                   error:&error];
             
             NSString *result = [json objectForKey:@"result"];
             NSLog(@"Result=%@", result);
             if([result isEqualToString:RESULT_SUCCES]) {
                 
                 NSString *value = [json objectForKey:@"value"];
                 NSLog(@"Value=%@", value);
                 NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                 NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                 
                 arrCountries = [[NSMutableArray alloc]init];
                 arrIdCountries = [[NSMutableArray alloc]init];
                 
                 arrStates = [[NSMutableArray alloc]init];
                 arrIdStates = [[NSMutableArray alloc]init];
                 
                 arrCities = [[NSMutableArray alloc]init];
                 arrIdCities = [[NSMutableArray alloc]init];
                 
                 for(int i = 0; i < arr.count; i++) {
                     
                     NSDictionary *dict = (NSDictionary *)[arr objectAtIndex:i];
                     NSString *title = [dict objectForKey:@"name"];
                     NSString *idStream = [dict objectForKey:@"idCountries"];
                     NSLog(@"NAme=%@", title);
                     NSLog(@"Id=%@", idStream);
                     
                     [arrCountries addObject:title];
                     [arrIdCountries addObject:idStream];
                     
                 }

                 [_pickerSelectCountry reloadAllComponents];
                 
                 [self downloadState:0];
                 
             }
             
         }
         
     }];
    
}


- (void)downloadState: (int) idCountry {
    
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"idCountry\": \"%@\"}]", PID, [arrIdCountries objectAtIndex:idCountry]];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_STATES];
    NSLog(@"URL=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if(error == nil) {
             
             arrStates = [[NSMutableArray alloc]init];
             arrIdStates = [[NSMutableArray alloc]init];
             
             arrCities = [[NSMutableArray alloc]init];
             arrIdCities = [[NSMutableArray alloc]init];
             
             NSError* error;
             NSDictionary* json = [NSJSONSerialization
                                   JSONObjectWithData:data //1
                                   
                                   options:kNilOptions
                                   error:&error];
             
             NSString *result = [json objectForKey:@"result"];
             NSLog(@"Result=%@", result);
             if([result isEqualToString:RESULT_SUCCES]) {
                 
                 NSString *value = [json objectForKey:@"value"];
                 NSLog(@"Value=%@", value);
                 NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                 NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                 
                 for(int j = 0; j < arr.count; j++) {
                     
                     NSDictionary *dict = (NSDictionary *)[arr objectAtIndex:j];
                     NSString *title = [dict objectForKey:@"name"];
                     NSString *mapping = [dict objectForKey:@"statesmapped"];
                     NSString *idProductitems = [dict objectForKey:@"idStates"];
                     NSLog(@"NAme=%@, mapping=%@", title, mapping);
                     
                     
                     if([mapping intValue] == 1) {
                     
                         [arrStates addObject:title];
                         [arrIdStates addObject:idProductitems];
                         
                     }
                     
                     
                 }
                 
                 
                 [_pickerSelectState reloadAllComponents];
                 
                 [self downloadCity:0];
                 
             }
             
         }
         
     }];
    
}

- (void)downloadCity: (int) idState {
    
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"idState\": \"%@\"}]", PID, [arrIdStates objectAtIndex:idState]];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_CITIES];
    NSLog(@"URL=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if(error == nil) {
             
             arrCities = [[NSMutableArray alloc]init];
             arrIdCities = [[NSMutableArray alloc]init];
             
             NSError* error;
             NSDictionary* json = [NSJSONSerialization
                                   JSONObjectWithData:data //1
                                   
                                   options:kNilOptions
                                   error:&error];
             
             NSString *result = [json objectForKey:@"result"];
             NSLog(@"Result=%@", result);
             if([result isEqualToString:RESULT_SUCCES]) {
                 
                 NSString *value = [json objectForKey:@"value"];
                 NSLog(@"Value=%@", value);
                 NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                 NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                 
                 for(int j = 0; j < arr.count; j++) {
                     
                     NSDictionary *dict = (NSDictionary *)[arr objectAtIndex:j];
                     NSString *title = [dict objectForKey:@"name"];
                     NSString *mapping = [dict objectForKey:@"mapped"];
                     NSString *idProductitems = [dict objectForKey:@"idCities"];
                     NSLog(@"NAme=%@, mapping=%@", title, mapping);
                     
                     if([mapping integerValue] == 1) {
                     
                     [arrCities addObject:title];
                     [arrIdCities addObject:idProductitems];
                         
                     }
                     
                 }
                 
                 
                 [_pickerSelectCity reloadAllComponents];
                 
             }
             
         }
         
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _pickerSelectCity) {
        return arrCities.count;
    } else if(pickerView == _pickerSelectCountry){
        return arrCountries.count;
    } else if(pickerView == _pickerSelectState){
        return arrStates.count;
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if(pickerView == _pickerSelectCity) {
        return arrCities[row];
    } else if(pickerView == _pickerSelectCountry){
        return arrCountries[row];
    } else if(pickerView == _pickerSelectState){
        return arrStates[row];
    } else {
        return 0;
    }
}

-(IBAction)onsubmit:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Alert" message: @"Are you sure?" delegate: self cancelButtonTitle: @"YES"  otherButtonTitles:@"NO",nil];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex==0)
    {
        
        NSString *idCity = arrIdCities[[_pickerSelectCity selectedRowInComponent:0]];
        NSString *nameCity = arrCities[[_pickerSelectCity selectedRowInComponent:0]];
        
        NSString *idStates = arrIdStates[[_pickerSelectState selectedRowInComponent:0]];
        NSString *nameStates = arrStates[[_pickerSelectState selectedRowInComponent:0]];
        
        NSString *idCountries = arrIdCountries[[_pickerSelectCountry selectedRowInComponent:0]];
        NSString *nameCountries = arrCountries[[_pickerSelectCountry selectedRowInComponent:0]];
        
        NSDictionary *cvCountry = @{
                                 DB_COL_TYPE: DB_RECORD_TYPE_MY_COUNTRY
                                 };
        NSDictionary *cvState = @{
                                    DB_COL_TYPE: DB_RECORD_TYPE_MY_STATE
                                    };
        NSDictionary *cvCity = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_MY_CITY
                                  };
        
        [[DbHelper getSharedInstance] deleteRecord:cvCountry];
        [[DbHelper getSharedInstance] deleteRecord:cvState];
        [[DbHelper getSharedInstance] deleteRecord:cvCity];
        
        cvCountry = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_MY_COUNTRY,
                   DB_COL_SRV_ID: idCountries,
                   DB_COL_NAME: nameCountries
                   };
        
        cvState = @{
                      DB_COL_TYPE: DB_RECORD_TYPE_MY_STATE,
                      DB_COL_SRV_ID: idStates,
                      DB_COL_NAME: nameStates
                      };
        
        cvCity = @{
                    DB_COL_TYPE: DB_RECORD_TYPE_MY_CITY,
                    DB_COL_SRV_ID: idCity,
                    DB_COL_NAME: nameCity
                    };
        
        [[DbHelper getSharedInstance] insertRecord:cvCountry];
        [[DbHelper getSharedInstance] insertRecord:cvState];
        [[DbHelper getSharedInstance] insertRecord:cvCity];
        
        if(self.fromStart) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        
    }
    
}

#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if(pickerView == _pickerSelectCity) {
        
    } else if(pickerView == _pickerSelectCountry){
        [self downloadState:row];
    } else if(pickerView == _pickerSelectState){
        [self downloadCity:row];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
