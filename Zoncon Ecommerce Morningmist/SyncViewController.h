//
//  SyncViewController.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 31/10/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncViewController : UIViewController <NSURLConnectionDelegate>

extern NSString *MY_COUNTRYID;
extern NSString *MY_COUNTRYNAME;
extern NSString *MY_STATEID;
extern NSString *MY_STATENAME;
extern NSString *MY_CITYID;
extern NSString *MY_CITYNAME;
extern NSString *MY_EMAIL;
extern NSString *MY_NAME;
extern NSString *MY_TOKEN;
extern NSString *PUSH_TOKEN;
extern NSMutableArray *ARR_RATES;
extern CGFloat SCREEN_HEIGHT;
extern CGFloat SCREEN_WIDTH;
extern BOOL IS_SIGNED_IN;
extern BOOL IS_OPENED_FROM_DETAIL;
extern BOOL IS_OPENED_FROM_MENU;
extern BOOL IS_OPENED_FROM_FORGOT;
extern BOOL IS_OPENED_FROM_RESET;
extern BOOL IS_OPENED_FROM_CART;

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@property (nonatomic, strong) NSURLConnection *connLogin;
@property (nonatomic, strong) IBOutlet UIImageView *picture;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityView;

@end
