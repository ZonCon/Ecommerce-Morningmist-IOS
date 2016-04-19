//
//  AppDelegate.h
//  Zoncon Ecommerce Morningmist
//
//  Created by Hrushikesh  on 14/04/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "NavigationViewController.h"
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate>

@property (nonatomic, retain) NSString *notifParams;
@property (nonatomic, strong) NavigationViewController *navController;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSURLConnection *connRegisterToken;

@end

