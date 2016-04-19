//
//  PoliciesListCollectionViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 04/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoliciesListCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *arrTitles;
@property (nonatomic, strong) NSMutableArray *arrSubTitles;
@property (nonatomic, strong) NSMutableArray *arrIds;

@property (nonatomic, strong) NSString *_idSrv;

@end
