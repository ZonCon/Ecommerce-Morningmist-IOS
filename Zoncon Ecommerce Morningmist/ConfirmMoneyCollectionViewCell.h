//
//  ConfirmMoneyCollectionViewCell.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 28/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmMoneyCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *textSubtotalLabel;
@property (nonatomic, strong) IBOutlet UILabel *textSubtotal;
@property (nonatomic, strong) IBOutlet UILabel *textCouponTotal;
@property (nonatomic, strong) IBOutlet UILabel *textCouponLabel;
@property (nonatomic, strong) IBOutlet UILabel *textTaxes;
@property (nonatomic, strong) IBOutlet UILabel *textTaxesLabel;
@property (nonatomic, strong) IBOutlet UILabel *textTaxesTotal;
@property (nonatomic, strong) IBOutlet UILabel *textTaxesTotalLabel;

@end
