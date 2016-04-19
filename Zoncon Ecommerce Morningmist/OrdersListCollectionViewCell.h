//
//  OrdersListCollectionViewCell.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 21/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrdersListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *textPrice;
@property (nonatomic, strong) IBOutlet UILabel *textDate;
@property (nonatomic, strong) IBOutlet UILabel *textDesc;
@property (nonatomic, strong) IBOutlet UILabel *textOrder;

@end
