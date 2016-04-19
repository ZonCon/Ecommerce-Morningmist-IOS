//
//  NavigationViewController.h
//  Zoncon Ecommerce Morningmist
//
//  Created by Hrushikesh  on 15/04/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "TaxRecord.h"
#import "CouponRecord.h"
#import <UIKit/UIKit.h>

@interface NavigationViewController : UINavigationController <UITabBarControllerDelegate, UITabBarDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSString *notifParams;

@property (nonatomic, strong) UILabel *labelBadge;

- (void)logout;
- (void)removeAppliedCouponToCart;
- (void)addToCart:(NSString *)idStreamSrv idItemSrv:(NSString *)idItemSrv idDiscount:(NSString *)idDiscount bookingPrice:(NSString *)bookingPrice;
- (NSDictionary *)getDiscount: (NSString *)idSrv;
- (NSString *)getMetalRate: (int)index;
- (CouponRecord *)getCouponAppliedToCart;
- (void)removeItemsFromCart;
- (void)showCartCount;
- (void)hideCartCount;
- (TaxRecord *)getTax1;
- (BOOL)isNetworkAvailable;
- (void)setCartBadgeByCountingCartItems;

@end
