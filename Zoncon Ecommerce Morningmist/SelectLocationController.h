//
//  SelectBranchTableViewController.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 22/11/15.
//  Copyright © 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectLocationController : UITableViewController <NSURLConnectionDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property Boolean fromStart;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerSelectCity;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerSelectState;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerSelectCountry;
-(IBAction)onsubmit:(id)sender;

@end
