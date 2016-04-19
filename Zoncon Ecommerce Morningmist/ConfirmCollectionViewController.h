//
//  ConfirmCollectionViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 28/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfirmMoneyCollectionViewCell.h"
#import "ConfirmShippingCollectionViewCell.h"

@interface ConfirmCollectionViewController : UICollectionViewController <NSURLConnectionDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property(nonatomic, strong) NSURLConnection *connDownloadCart;
@property(nonatomic, strong) NSURLConnection *connOrderNew;
@property(nonatomic, strong) NSMutableData *responseData;

@property(nonatomic, strong) NSMutableArray *arrIdStreams;
@property(nonatomic, strong) NSMutableArray *arrIdItems;
@property(nonatomic, strong) NSMutableArray *arrIdCart;
@property(nonatomic, strong) NSMutableArray *arrTitles;
@property(nonatomic, strong) NSMutableArray *arrQuantities;
@property(nonatomic, strong) NSMutableArray *arrWeights;
@property(nonatomic, strong) NSMutableArray *arrPrices;
@property(nonatomic, strong) NSMutableArray *arrDiscountedPrices;
@property(nonatomic, strong) NSMutableArray *arrDiscountCodes;
@property(nonatomic, strong) NSMutableArray *arrDiscountTypes;
@property(nonatomic, strong) NSMutableArray *arrDiscountValues;
@property(nonatomic, strong) NSMutableArray *arrBookingPrices;
@property(nonatomic, strong) NSMutableArray *arrPictures;

@property(nonatomic, strong) NSString *billingName;
@property(nonatomic, strong) NSString *billingAddress;
@property(nonatomic, strong) NSString *billingPhone;
@property(nonatomic, strong) NSString *billingPincode;

@property(nonatomic, strong) NSString *tax1Label;
@property(nonatomic, strong) NSString *tax1Value;

@property(nonatomic, strong) NSString *pgPostData;

@property(nonatomic, strong) UIAlertView *alertCheckInternet;
@property(nonatomic, strong) UIAlertView *alertConfirmRemove;
@property(nonatomic, strong) NavigationViewController *nav;

@property(nonatomic, strong) ConfirmMoneyCollectionViewCell *cellMoney;
@property(nonatomic, strong) ConfirmShippingCollectionViewCell *cellShipping;

@property(nonatomic) CGFloat subTotal;
@property(nonatomic) CGFloat totalAfterCoupon;
@property(nonatomic) CGFloat totalAfterTaxes;

@property(nonatomic) Boolean containsBooking;
@property(nonatomic) Boolean containsDiscount;


@end
