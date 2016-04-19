//
//  CartCollectionViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 22/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartCollectionViewController : UICollectionViewController <NSURLConnectionDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property(nonatomic, strong) NSURLConnection *connDownloadCart;
@property(nonatomic, strong) NSURLConnection *connValidateCoupon;
@property(nonatomic, strong) NSMutableData *responseData;

@property(nonatomic, strong) NSMutableArray *arrIdStreams;
@property(nonatomic, strong) NSMutableArray *arrIdItems;
@property(nonatomic, strong) NSMutableArray *arrIdCart;
@property(nonatomic, strong) NSMutableArray *arrTitles;
@property(nonatomic, strong) NSMutableArray *arrQuantities;
@property(nonatomic, strong) NSMutableArray *arrPrices;
@property(nonatomic, strong) NSMutableArray *arrDiscountedPrices;
@property(nonatomic, strong) NSMutableArray *arrBookingPrices;
@property(nonatomic, strong) NSMutableArray *arrPictures;

@property(nonatomic, strong) NSString *tax1Label;
@property(nonatomic, strong) NSString *tax1Value;

@property(nonatomic, strong) UIAlertView *alertCheckInternet;
@property(nonatomic, strong) UIAlertView *alertConfirmRemove;
@property(nonatomic, strong) NavigationViewController *nav;


- (IBAction) changeQuantity:(id)sender;

@end
