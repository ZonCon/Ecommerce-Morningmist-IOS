//
//  PaymentViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 01/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>

@property(nonatomic, strong) NSString *paymentGatewayPost;
@property(nonatomic, strong) IBOutlet UIWebView *webview;
@property(nonatomic, strong) NSURLConnection *connDownloadCart;
@property(nonatomic, strong) NSString *idOrder;

@property(nonatomic, strong) NavigationViewController *nav;

@end
