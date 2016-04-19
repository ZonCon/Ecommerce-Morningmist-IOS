//
//  OrdersListCollectionViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 21/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrdersListCollectionViewController : UICollectionViewController <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connList;
@property (nonatomic, strong) NSMutableArray *arrTime;
@property (nonatomic, strong) NSMutableArray *arrPrice;
@property (nonatomic, strong) NSMutableArray *arrDesc;
@property (nonatomic, strong) NSMutableArray *arrOrders;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) NSString *_idSrv;


@end
