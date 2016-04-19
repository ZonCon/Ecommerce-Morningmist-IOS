//
//  ConfirmShippingCollectionViewCell.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 28/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmShippingCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *textName;
@property (nonatomic, strong) IBOutlet UILabel *textAddress;
@property (nonatomic, strong) IBOutlet UILabel *textPincode;
@property (nonatomic, strong) IBOutlet UILabel *textCity;
@property (nonatomic, strong) IBOutlet UILabel *textState;
@property (nonatomic, strong) IBOutlet UILabel *textCountry;
@property (nonatomic, strong) IBOutlet UILabel *textEmail;
@property (nonatomic, strong) IBOutlet UILabel *textPhone;
@property (nonatomic, strong) IBOutlet UILabel *textTerms;

@end
