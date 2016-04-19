//
//  NavigationViewController.m
//  Zoncon Ecommerce Morningmist
//
//  Created by Hrushikesh  on 15/04/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#include<unistd.h>
#include<netdb.h>
#import "globals.h"
#import "DbHelper.h"
#import "AppDelegate.h"
#import "SyncViewController.h"
#import <objc/runtime.h>
#import "NavigationViewController.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

const char keyIdStreamSrv;
const char keyIdItemSrv;
const char keyIdDiscount;
const char keyBookingPrice;
@synthesize notifParams = _notifParams;
@synthesize labelBadge = _labelBadge;
UIAlertView *alertConfirmAddToCart;
UIAlertView *alertMaxCartLimit;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    
    [self setCartBadgeByCountingCartItems];
    
    CGFloat widthOfScreen  = [[UIScreen mainScreen] bounds].size.width;
    _labelBadge = [[UILabel alloc] initWithFrame:CGRectMake(widthOfScreen - 25, 5, 20, 20)];
    _labelBadge.backgroundColor = [UIColor redColor];
    _labelBadge.textColor = [UIColor whiteColor];
    _labelBadge.textAlignment = NSTextAlignmentCenter;
    _labelBadge.text = @"0";
    _labelBadge.layer.masksToBounds = YES;
    _labelBadge.layer.cornerRadius = 10;
    _labelBadge.font = [UIFont systemFontOfSize:10];
    [self.navigationBar addSubview:_labelBadge];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSDictionary *)getDiscount: (NSString *)idSrv {
    
    NSDictionary *cv = @{
                         DB_COL_TYPE: DB_RECORD_TYPE_DISCOUNT,
                         DB_COL_SRV_ID: idSrv,
                         };
    
    NSMutableArray *arr = [[DbHelper getSharedInstance] retrieveRecords:cv];
    if(arr.count > 0) {
        NSDictionary *ret = [arr objectAtIndex:0];
        return ret;
    } else {
        return nil;
    }
    
}

- (NSString *)getMetalRate: (int)index {
    
    if(index < ARR_RATES.count) {
        
        return ARR_RATES[index];
        
    } else {
        
        return @"";
        
    }
    
}

- (void)logout {
    
    MY_EMAIL = @"";
    MY_TOKEN = @"";
    MY_COUNTRYID = @"";
    MY_COUNTRYNAME = @"";
    MY_STATEID = @"";
    MY_STATENAME = @"";
    MY_CITYID = @"";
    MY_CITYNAME = @"";
    IS_SIGNED_IN = false;
    NSDictionary *cvEmail = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                              };
    [[DbHelper getSharedInstance] deleteRecord:cvEmail];
    NSDictionary *cvToken = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_TOKEN
                              };
    [[DbHelper getSharedInstance] deleteRecord:cvToken];
    NSDictionary *cvBranchstream = @{
                                     DB_COL_TYPE: DB_RECORD_TYPE_BRANCHSTREAM
                                     };
    [[DbHelper getSharedInstance] deleteRecord:cvBranchstream];
    NSDictionary *cvBranchitem = @{
                                   DB_COL_TYPE: DB_RECORD_TYPE_BRANCHITEM
                                   };
    [[DbHelper getSharedInstance] deleteRecord:cvBranchitem];
    
}


- (void)setCartBadgeByCountingCartItems {
    
    NSString *_idOpenCart = @"";
    NSDictionary *map = @{
                          DB_COL_TYPE: DB_RECORD_TYPE_CART,
                          DB_COL_CART_ISOPEN: DB_RECORD_VALUE_CART_OPEN
                          };
    NSMutableArray *recordsOpenCart = [[DbHelper getSharedInstance] retrieveRecords:map];
    
    if(recordsOpenCart.count > 0) {
        
        // Open Cart Exists so retrieve its handle
        
        map = [recordsOpenCart objectAtIndex:0];
        _idOpenCart = [map objectForKey:DB_COL_ID];
        
        map = @{
                DB_COL_TYPE: DB_RECORD_TYPE_CART_ITEM,
                DB_COL_FOREIGN_KEY: _idOpenCart
                };
        NSMutableArray *recordsItemInCart = [[DbHelper getSharedInstance] retrieveRecords:map];
        
        
        if(recordsItemInCart.count > 0) {
            _labelBadge.text = [NSString stringWithFormat:@"%d", recordsItemInCart.count];
        } else {
            NSLog(@"Setting badge valie nil");
            _labelBadge.text = [NSString stringWithFormat:@"%d", recordsItemInCart.count];
        }
        
    }
    
}


- (void)addToCart:(NSString *)idStreamSrv idItemSrv:(NSString *)idItemSrv idDiscount:(NSString *)idDiscount bookingPrice:(NSString *)bookingPrice {
    
    alertConfirmAddToCart = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                       message:@"Are you sure?"
                                                      delegate:self
                                             cancelButtonTitle:@"YES"
                                             otherButtonTitles:@"NO", nil];
    [alertConfirmAddToCart show];
    
    objc_setAssociatedObject(alertConfirmAddToCart, &keyIdStreamSrv, idStreamSrv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alertConfirmAddToCart, &keyIdItemSrv, idItemSrv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alertConfirmAddToCart, &keyIdDiscount, idDiscount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alertConfirmAddToCart, &keyBookingPrice, bookingPrice, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}


- (CouponRecord *)getCouponAppliedToCart {
    
    
    NSDictionary *map = @{
                          DB_COL_TYPE: DB_RECORD_TYPE_CART,
                          DB_COL_CART_ISOPEN: DB_RECORD_VALUE_CART_OPEN
                          };
    NSMutableArray *recordsOpenCart = [[DbHelper getSharedInstance] retrieveRecords:map];
    
    if(recordsOpenCart.count > 0) {
        
        NSDictionary *mapExisting = [recordsOpenCart objectAtIndex:0];
        NSString *idCoupon = [mapExisting objectForKey:DB_COL_DISCOUNT];
        if(idCoupon.length > 0) {
            
            map = @{
                    DB_COL_TYPE: DB_RECORD_TYPE_COUPON,
                    DB_COL_SRV_ID: idCoupon
                    };
            
            NSMutableArray *recordsCoupons = [[DbHelper getSharedInstance] retrieveRecords:map];
            
            if(recordsCoupons.count > 0) {
                
                map = [recordsCoupons objectAtIndex:0];
                
                CouponRecord *coupon = [[CouponRecord alloc] init];
                coupon.code = [map objectForKey:DB_COL_NAME];
                coupon.type = [map objectForKey:DB_COL_TITLE];
                coupon.value = [map objectForKey:DB_COL_PRICE];
                coupon.idCoupon = [map objectForKey:DB_COL_SRV_ID];
                coupon.allowDoubleDiscouting = [map objectForKey:DB_COL_CAPTION];
                coupon.maxVal = [map objectForKey:DB_COL_EXTRA_1];
                coupon.minPurchase = [map objectForKey:DB_COL_EXTRA_2];
                
                return coupon;
                
            } else {
                return Nil;
            }
            
        } else {
            return Nil;
        }
        
    } else {
        return Nil;
    }
    
    
}

- (void)removeItemsFromCart {
    
    NSDictionary *map = @{
                          DB_COL_TYPE: DB_RECORD_TYPE_CART_ITEM
                          };
    [[DbHelper getSharedInstance] deleteRecord:map];
    
    map = @{
            DB_COL_TYPE: DB_RECORD_TYPE_CART
            };
    [[DbHelper getSharedInstance] deleteRecord:map];
    //[[self.tabBar.items objectAtIndex:4] setBadgeValue:nil];
    
}

- (void)removeAppliedCouponToCart {
    
    NSDictionary *map = @{
                          DB_COL_TYPE: DB_RECORD_TYPE_CART
                          };
    NSDictionary *mapExisting = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_CART
                                  };
    NSMutableArray *recordsOfCart = [[DbHelper getSharedInstance] retrieveRecords:map];
    
    if(recordsOfCart.count > 0) {
        
        map = [recordsOfCart objectAtIndex:0];
        map = @{
                DB_COL_TYPE: DB_RECORD_TYPE_CART,
                DB_COL_DISCOUNT: @""
                };
        [[DbHelper getSharedInstance] updateRecord:map whereRecord:mapExisting];
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView == alertConfirmAddToCart) {
        
        if(buttonIndex == 1) {
            return;
        }
        
        NSString *idStreamSrv = objc_getAssociatedObject(alertView, &keyIdStreamSrv);
        NSString *idItemSrv = objc_getAssociatedObject(alertView, &keyIdItemSrv);
        NSString *idDiscount = objc_getAssociatedObject(alertView, &keyIdDiscount);
        NSString *bookingPrice = objc_getAssociatedObject(alertView, &keyBookingPrice);
        
        //Remove Applied Coupons
        [self removeAppliedCouponToCart];
        
        //
        // If no open cart exists, create a new open cart and insert the item into the newly opened cart
        // Else if an open cart exists insert the item into the existing open cart
        //
        
        NSString *_idOpenCart = @"";
        NSDictionary *map = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_CART,
                              DB_COL_CART_ISOPEN: DB_RECORD_VALUE_CART_OPEN
                              };
        NSMutableArray *recordsOpenCart = [[DbHelper getSharedInstance] retrieveRecords:map];
        
        if(recordsOpenCart.count > 0) {
            
            // Open Cart Exists so retrieve its handle
            
            map = [recordsOpenCart objectAtIndex:0];
            _idOpenCart = [map objectForKey:DB_COL_ID];
            
            
        } else {
            
            // Open Cart Does Not Exist Create an open cart and retrieve its handle
            
            CGFloat tsF = [[NSDate date] timeIntervalSince1970];
            int ts = tsF * 1000.0;
            map = @{
                    DB_COL_TYPE: DB_RECORD_TYPE_CART,
                    DB_COL_TIMESTAMP: [NSString stringWithFormat:@"%d", ts],
                    DB_COL_CART_ISOPEN: DB_RECORD_VALUE_CART_OPEN
                    };
            [[DbHelper getSharedInstance] insertRecord:map];
            _idOpenCart = [[DbHelper getSharedInstance] retrieve_id:map];
            
            
        }
        
        // Check if an entry exists in the cart for the current item
        
        map = @{
                DB_COL_TYPE: DB_RECORD_TYPE_CART_ITEM,
                DB_COL_CART_ITEM_STREAM_ID: idStreamSrv,
                DB_COL_CART_ITEM_ITEM_ID: idItemSrv,
                DB_COL_FOREIGN_KEY: _idOpenCart
                };
        NSMutableArray *recordsItemInCart = [[DbHelper getSharedInstance] retrieveRecords:map];
        
        if(recordsItemInCart.count > 0) {
            
            map = [recordsItemInCart objectAtIndex:0];
            NSString *quantityS = [map objectForKey:DB_COL_CART_ITEM_QUANTITY];
            int newQuantity = [quantityS integerValue] + 1;
            
            if(newQuantity <= MAX_CART_QUANTITY) {
                
                map = @{
                        DB_COL_TYPE: DB_RECORD_TYPE_CART_ITEM,
                        DB_COL_CART_ITEM_STREAM_ID: idStreamSrv,
                        DB_COL_CART_ITEM_ITEM_ID: idItemSrv,
                        DB_COL_FOREIGN_KEY: _idOpenCart,
                        DB_COL_DISCOUNT: idDiscount,
                        DB_COL_BOOKING: bookingPrice
                        };
                
                NSDictionary *mapUpdated = @{
                                             DB_COL_CART_ITEM_QUANTITY: [NSString stringWithFormat:@"%d", newQuantity]
                                             };
                [[DbHelper getSharedInstance] updateRecord:mapUpdated whereRecord:map];
                
            } else {
                
                alertMaxCartLimit = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                               message:@"Cannot add items to cart anymore. Max limit reached."
                                                              delegate:self
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
                [alertMaxCartLimit show];
                return;
                
            }
            
        } else {
            
            // Entry for the current item does not exist, so create it setting quantity to 1
            
            map = @{
                    DB_COL_TYPE: DB_RECORD_TYPE_CART_ITEM,
                    DB_COL_CART_ITEM_STREAM_ID: idStreamSrv,
                    DB_COL_CART_ITEM_ITEM_ID: idItemSrv,
                    DB_COL_CART_ITEM_QUANTITY: @"1",
                    DB_COL_FOREIGN_KEY: _idOpenCart,
                    DB_COL_DISCOUNT: idDiscount,
                    DB_COL_BOOKING: bookingPrice
                    };
            [[DbHelper getSharedInstance] insertRecord:map];
            
        }
        
        [self setCartBadgeByCountingCartItems];
        
    }
    
}

-(BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
        return NO;
    }
    else{
        return YES;
    }
    
}

- (void)showCartCount;
{
    [_labelBadge setHidden:NO];
}

- (void)hideCartCount;
{
    [_labelBadge setHidden:YES];
}


- (TaxRecord *)getTax1 {
    
    NSDictionary *map = @{
                          DB_COL_TYPE: DB_RECORD_TYPE_TAX_1
                          };
    NSMutableArray *list = [[DbHelper getSharedInstance] retrieveRecords:map];
    if(list.count > 0) {
        
        map = [list objectAtIndex:0];
        
        TaxRecord *record = [[TaxRecord alloc] init];
        record.label = [map objectForKey:DB_COL_TITLE];
        record.value = [map objectForKey:DB_COL_SUBTITLE];
        return record;
    }
    
    return Nil;
    
}

@end
