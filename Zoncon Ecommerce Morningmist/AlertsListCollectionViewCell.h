//
//  AlertsListCollectionViewCell.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 02/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertsListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *picture;
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *subtitle;
@property (nonatomic, strong) IBOutlet UILabel *timestamp;

@end
