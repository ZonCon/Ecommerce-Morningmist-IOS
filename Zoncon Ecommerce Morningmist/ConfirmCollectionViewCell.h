//
//  ConfirmCollectionViewCell.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 28/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *pictureProduct;
@property (nonatomic, strong) IBOutlet UILabel *textTitle;
@property (nonatomic, strong) IBOutlet UILabel *textPrice;
@property (nonatomic, strong) IBOutlet UILabel *textDiscount;
@property (nonatomic, strong) IBOutlet UILabel *textBooking;
@property (nonatomic, strong) IBOutlet UITextField *fieldQuantity;
@property (nonatomic, strong) IBOutlet UILabel *textQLabel;

@end
