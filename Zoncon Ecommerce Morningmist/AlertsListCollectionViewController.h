//
//  AlertsListCollectionViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 02/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertsListCollectionViewController : UICollectionViewController <NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableArray *arrTitles;
@property (nonatomic, strong) NSMutableArray *arrSubTitles;
@property (nonatomic, strong) NSMutableArray *arrTimes;
@property (nonatomic, strong) NSMutableArray *arrPictures;
@property (nonatomic, strong) NSMutableArray *arrIds;

@property (nonatomic, strong) UILabel *footerLabel;

@property (nonatomic, strong) NSString *_idSrv;

@end
