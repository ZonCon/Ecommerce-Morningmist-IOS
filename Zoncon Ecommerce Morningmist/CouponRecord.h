//
//  CouponRecord.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 25/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponRecord : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *idCoupon;
@property (nonatomic, strong) NSString *allowDoubleDiscouting;
@property (nonatomic, strong) NSString *maxVal;
@property (nonatomic, strong) NSString *minPurchase;

@end
