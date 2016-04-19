//
//  CartCollectionViewCell.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 22/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *pictureProduct;
@property (nonatomic, strong) IBOutlet UILabel *textTitle;
@property (nonatomic, strong) IBOutlet UILabel *textPrice;
@property (nonatomic, strong) IBOutlet UILabel *textDiscount;
@property (nonatomic, strong) IBOutlet UILabel *textBooking;
@property (nonatomic, strong) IBOutlet UILabel *textQLabel;
@property (nonatomic, strong) IBOutlet UIImageView *textRemove;
@property (nonatomic, strong) IBOutlet UITextField *fieldQuantity;

@end
