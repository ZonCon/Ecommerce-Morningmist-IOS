//
//  AbsWorldListCollectionViewCell.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 15/11/15.
//  Copyright © 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopItemsListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *textTitle;
@property (nonatomic, strong) IBOutlet UILabel *textPrice;
@property (nonatomic, strong) IBOutlet UILabel *textDiscount;
@property (nonatomic, strong) IBOutlet UILabel *textDiscountPrice;
@property (nonatomic, strong) IBOutlet UILabel *textBooking;
@property (nonatomic, strong) IBOutlet UILabel *textCart;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end
