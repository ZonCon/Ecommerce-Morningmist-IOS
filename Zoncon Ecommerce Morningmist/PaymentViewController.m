//
//  PaymentViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 01/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "SyncViewController.h"
#import "NavigationViewController.h"
#import "SelectLocationController.h"
#import "globals.h"
#import "DbHelper.h"
#import "AppDelegate.h"
#import "PaymentViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

@synthesize paymentGatewayPost = _paymentGatewayPost;
@synthesize webview = _webview;
@synthesize connDownloadCart = _connDownloadCart;
@synthesize idOrder = _idOrder;
@synthesize nav = _nav;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"Order No = %@", _idOrder);
    
    self.navigationItem.title = @"Payment";
    
    NSURL *url = [NSURL URLWithString: PG_IFRAME_URL];
    NSString *body = _paymentGatewayPost;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [_webview loadRequest: request];
    
    _webview.delegate = self;
    
    _nav = (NavigationViewController *)self.navigationController;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    NSLog(@"Requested url: %@", [_webview.request mainDocumentURL]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSLog(@"Loaded url: %@", [_webview.request mainDocumentURL]);
    
    NSString *yourHTMLSourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    
    //NSLog(@"Loaded url text: %@", yourHTMLSourceCodeString);
    
    NSString *sentence = yourHTMLSourceCodeString;
    NSString *wordSuccess = @"Payment Status : SUCCESS";
    NSString *wordFailure = @"Payment Status :";
    
    if ([sentence rangeOfString:wordSuccess].location != NSNotFound) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:[NSString stringWithFormat:@"Payment is complete! You will receive a confirmation email shortly! Your Order No. is %@", _idOrder]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag = 0;
        [alert show];
        [_nav removeItemsFromCart];
        [_nav setCartBadgeByCountingCartItems];
        
        
    } else if ([sentence rangeOfString:wordFailure].location != NSNotFound) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Payment could not be completed!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        [_nav removeItemsFromCart];
        [_nav setCartBadgeByCountingCartItems];
        //[tab setSelectedIndex:0];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_nav removeItemsFromCart];
    [_nav setCartBadgeByCountingCartItems];
}

@end
