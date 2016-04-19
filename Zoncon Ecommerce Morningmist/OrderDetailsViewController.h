//
//  OrderDetailsViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 22/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailsViewController : UIViewController <NSURLConnectionDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scView;
@property (nonatomic, strong) NSString *idOrder;
@property (nonatomic, strong) NSURLConnection *connList;
@property (nonatomic, strong) UIView *myContentView;

@end
