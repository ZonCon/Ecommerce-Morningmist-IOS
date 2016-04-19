//
//  ImageScreenViewController.h
//  Metasurgasia
//
//  Created by Hrushikesh  on 21/06/14.
//  Copyright (c) 2014 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScreenViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic) NSString *image;

@property (nonatomic, strong) IBOutlet UIImageView *newsImage;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

-(IBAction)Close:(id)sender;
-(IBAction)Save:(id)sender;

@end
