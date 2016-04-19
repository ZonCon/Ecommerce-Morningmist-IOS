//
//  OrderDetailsViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 22/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ShopItemDetailsViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "NavigationViewController.h"
#import "SyncViewController.h"
#import "ImageScreenViewController.h"
#import "OrderDetailsViewController.h"

@interface OrderDetailsViewController ()

@end

@implementation OrderDetailsViewController

static NSMutableData *_responseData;

@synthesize scView = _scView;
@synthesize idOrder = _idOrder;
@synthesize connList = _connList;
@synthesize myContentView = _myContentView;

int topY;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"Order %@", _idOrder];
    
    NavigationViewController *nav = (NavigationViewController *)self.navigationController;
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _myContentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    
    [_scView addSubview:_myContentView];
    
    topY = 0;
    
    if([nav isNetworkAvailable]) {
        [self initiateDownload];
    }   else {
        
        //[tab setSelectedIndex:0];
        UIAlertView *alertCheckInternet = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                     message:@"You are not connected to the Internet!"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
        [alertCheckInternet show];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initiateDownload {
    
    NSString *orderNo = [_idOrder stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_ORDERS_SINGLE];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"token\": \"%@\", \"idOrder\": \"%@\"}]", PID, MY_EMAIL, MY_TOKEN, orderNo];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connList = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if(connection == _connList) {
        
        NSString *data = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
        NSLog(@"Data=%@", data);
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            NSString* value = [json objectForKey:@"value"];
            NSLog(@"value=%@", value);
            NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArr = [NSJSONSerialization
                                JSONObjectWithData:jsonData //1
                                options:kNilOptions
                                error:&error];
            NSLog(@"value=%@", value);
            
            int margin = 20;
            
            if(jsonArr.count > 0) {
                
                for(int i = 0; i < jsonArr.count; i++) {
                
                    NSDictionary *json = [jsonArr objectAtIndex:i];
                    NSString *nameCustomer = [json objectForKey:@"nameCustomer"];
                    NSString *emailCustomer = [json objectForKey:@"emailCustomer"];
                    NSString *phoneCustomer = [json objectForKey:@"phoneCustomer"];
                    NSString *addressCustomer = [json objectForKey:@"address"];
                    NSString *country = [json objectForKey:@"country"];
                    NSString *state = [json objectForKey:@"state"];
                    NSString *city = [json objectForKey:@"city"];
                    NSString *subtotal = [json objectForKey:@"priceOriginal"];
                    NSString *totalAfterDiscount = [json objectForKey:@"price"];
                    NSString *tax1Label = [json objectForKey:@"taxLabel1"];
                    NSString *tax1Value = [json objectForKey:@"taxValue1"];
                    NSString *taxedPrice = [json objectForKey:@"taxedPrice"];
                    NSString *timestamp = [json objectForKey:@"timestamp"];
                    NSString *status = [json objectForKey:@"status"];
                    NSMutableArray *arr = [json objectForKey:@"items"];
                    
                    topY = margin;
                    
                    for(int j = 0; j < arr.count; j++) {
                        
                        NSDictionary *jsonItem = [arr objectAtIndex:j];
                        NSString *title = [jsonItem objectForKey:@"name"];
                        NSString *quantity = [jsonItem objectForKey:@"quantity"];
                        NSString *price = [jsonItem objectForKey:@"price"];
                        NSString *priceOriginal = [jsonItem objectForKey:@"priceOriginal"];
                        NSString *bookingPrice = [jsonItem objectForKey:@"bookingPrice"];
                        
                        
                        UIFont *titleFont = [UIFont systemFontOfSize:13];
                        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/2 - margin, 100)];
                        labelTitle.backgroundColor = [UIColor clearColor];
                        labelTitle.textAlignment = NSTextAlignmentLeft; // UITextAlignmentCenter, UITextAlignmentLeft
                        labelTitle.text = [NSString stringWithFormat:@"%@ (%@)", title, quantity];
                        labelTitle.numberOfLines = 0;
                        labelTitle.textColor = TEXT_COLOR;
                        labelTitle.font = titleFont;
                        [labelTitle sizeToFit];
                        labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
                        [_myContentView addSubview:labelTitle];
                        
                        UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topY, SCREEN_WIDTH/2 - margin, 100)];
                        labelPrice.backgroundColor = [UIColor clearColor];
                        labelPrice.textAlignment = NSTextAlignmentRight;
                        labelPrice.text = [NSString stringWithFormat:@"INR %@", price];
                        labelPrice.numberOfLines = 0;
                        labelPrice.textColor = TEXT_COLOR;
                        labelPrice.font = titleFont;
                        [labelPrice sizeToFit];
                        labelPrice.lineBreakMode = NSLineBreakByWordWrapping;
                        [_myContentView addSubview:labelPrice];
                        
                        topY += labelTitle.frame.size.height;
                        
                        if([price floatValue] != [priceOriginal floatValue]) {
                            
                            NSDictionary* attributes = @{
                                                         NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                                         };
                            
                            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"INR %@", priceOriginal] attributes:attributes];
                            UIFont *priceOriginalFont = [UIFont systemFontOfSize:10];
                            UILabel *labelPriceOriginal = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topY, SCREEN_WIDTH/2 - margin, 100)];
                            labelPriceOriginal.backgroundColor = [UIColor clearColor];
                            labelPriceOriginal.textAlignment = NSTextAlignmentRight;
                            labelPriceOriginal.attributedText = attrText;
                            labelPriceOriginal.numberOfLines = 0;
                            labelPriceOriginal.textColor = TEXT_COLOR;
                            labelPriceOriginal.font = priceOriginalFont;
                            [labelPriceOriginal sizeToFit];
                            labelPriceOriginal.lineBreakMode = NSLineBreakByWordWrapping;
                            [_myContentView addSubview:labelPriceOriginal];
                            
                            topY += labelPriceOriginal.frame.size.height;
                            
                        }
                        
                        if(bookingPrice.length > 0) {
                            
                            UIFont *bookingFont = [UIFont systemFontOfSize:10];
                            UILabel *labelBooking = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/2 - margin, 100)];
                            labelBooking.backgroundColor = [UIColor clearColor];
                            labelBooking.textAlignment = NSTextAlignmentLeft;
                            labelBooking.text = @"Booking Price";
                            labelBooking.numberOfLines = 0;
                            labelBooking.textColor = TEXT_COLOR;
                            labelBooking.font = bookingFont;
                            [labelBooking sizeToFit];
                            labelBooking.lineBreakMode = NSLineBreakByWordWrapping;
                            [_myContentView addSubview:labelBooking];
                            
                            UILabel *labelBookingPrice = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topY, SCREEN_WIDTH/2 - margin, 100)];
                            labelBookingPrice.backgroundColor = [UIColor clearColor];
                            labelBookingPrice.textAlignment = NSTextAlignmentRight; // UITextAlignmentCenter, UITextAlignmentLeft
                            labelBookingPrice.text = [NSString stringWithFormat:@"INR %@", price];
                            labelBookingPrice.numberOfLines = 0;
                            labelBookingPrice.textColor = TEXT_COLOR;
                            labelBookingPrice.font = bookingFont;
                            [labelBookingPrice sizeToFit];
                            labelBookingPrice.lineBreakMode = NSLineBreakByWordWrapping;
                            [_myContentView addSubview:labelBookingPrice];
                            
                            topY += labelBooking.frame.size.height;
                            
                        }
                        
                        topY += margin;
                        
                        
                    }
                    
                    UIColor *grayColor = [UIColor colorWithRed:(150.0/255.0) green:(150.0/255.0) blue:(150.0/255.0) alpha:1.0];
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH - margin*2, 1)];
                    line.backgroundColor = [UIColor lightGrayColor];
                    [_myContentView addSubview:line];
                    
                    topY += (margin + 1);
                    
                    UIFont *titleFont = [UIFont systemFontOfSize:13];
                    UILabel *labelOriginal = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/2 - margin, 100)];
                    labelOriginal.backgroundColor = [UIColor clearColor];
                    labelOriginal.textAlignment = NSTextAlignmentLeft;
                    labelOriginal.text = [NSString stringWithFormat:@"SubTotal"];
                    labelOriginal.numberOfLines = 0;
                    labelOriginal.textColor = TEXT_COLOR;
                    labelOriginal.font = titleFont;
                    [labelOriginal sizeToFit];
                    labelOriginal.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelOriginal];
                    
                    UILabel *labelOriginalPrice = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topY, SCREEN_WIDTH/2 - margin, 100)];
                    labelOriginalPrice.backgroundColor = [UIColor clearColor];
                    labelOriginalPrice.textAlignment = NSTextAlignmentRight;
                    labelOriginalPrice.text = [NSString stringWithFormat:@"INR %@", subtotal];
                    labelOriginalPrice.numberOfLines = 0;
                    labelOriginalPrice.textColor = TEXT_COLOR;
                    labelOriginalPrice.font = titleFont;
                    [labelOriginalPrice sizeToFit];
                    labelOriginalPrice.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelOriginalPrice];
                    
                    topY += labelOriginalPrice.frame.size.height;
                    topY += margin;
                    
                    if(![subtotal isEqualToString:totalAfterDiscount]) {
                        
                        UILabel *labelDiscount = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/2 - margin, 100)];
                        labelDiscount.backgroundColor = [UIColor clearColor];
                        labelDiscount.textAlignment = NSTextAlignmentLeft;
                        labelDiscount.text = [NSString stringWithFormat:@"Discounted Total"];
                        labelDiscount.numberOfLines = 0;
                        labelDiscount.textColor = TEXT_COLOR;
                        labelDiscount.font = titleFont;
                        [labelDiscount sizeToFit];
                        labelDiscount.lineBreakMode = NSLineBreakByWordWrapping;
                        [_myContentView addSubview:labelDiscount];
                        
                        UILabel *labelDiscountedPrice = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topY, SCREEN_WIDTH/2 - margin, 100)];
                        labelDiscountedPrice.backgroundColor = [UIColor clearColor];
                        labelDiscountedPrice.textAlignment = NSTextAlignmentRight;
                        labelDiscountedPrice.text = [NSString stringWithFormat:@"INR %@", totalAfterDiscount];
                        labelDiscountedPrice.numberOfLines = 0;
                        labelDiscountedPrice.textColor = TEXT_COLOR;
                        labelDiscountedPrice.font = titleFont;
                        [labelDiscountedPrice sizeToFit];
                        labelDiscountedPrice.lineBreakMode = NSLineBreakByWordWrapping;
                        [_myContentView addSubview:labelDiscountedPrice];
                        
                        topY += labelDiscountedPrice.frame.size.height;
                        topY += margin;
                        
                    }
                    
                    if(tax1Label.length > 0 && tax1Value.length > 0) {
                        
                        UILabel *labelTax1 = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/2 - margin, 100)];
                        labelTax1.backgroundColor = [UIColor clearColor];
                        labelTax1.textAlignment = NSTextAlignmentLeft;
                        labelTax1.text = tax1Label;
                        labelTax1.numberOfLines = 0;
                        labelTax1.layer.shadowColor = [[UIColor blackColor] CGColor];
                        labelTax1.layer.shadowOffset = CGSizeMake(1.0, 1.0);
                        labelTax1.layer.shadowRadius = 1.0;
                        labelTax1.layer.shadowOpacity = 1.0;
                        labelTax1.layer.masksToBounds = NO;
                        labelTax1.layer.shouldRasterize = YES;
                        labelTax1.textColor = grayColor;
                        labelTax1.font = titleFont;
                        [labelTax1 sizeToFit];
                        labelTax1.lineBreakMode = NSLineBreakByWordWrapping;
                        [_myContentView addSubview:labelTax1];
                        
                        UILabel *labelTax1Value = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topY, SCREEN_WIDTH/2 - margin, 100)];
                        labelTax1Value.backgroundColor = [UIColor clearColor];
                        labelTax1Value.textAlignment = NSTextAlignmentRight; // UITextAlignmentCenter,
                        labelTax1Value.text = [NSString stringWithFormat:@"%@%%", tax1Value];
                        labelTax1Value.numberOfLines = 0;
                        labelTax1Value.textColor = TEXT_COLOR;
                        labelTax1Value.font = titleFont;
                        [labelTax1Value sizeToFit];
                        labelTax1Value.lineBreakMode = NSLineBreakByWordWrapping;
                        [_myContentView addSubview:labelTax1Value];
                        
                        topY += labelTax1Value.frame.size.height;
                        topY += margin;
                        
                    }
                    
                    UILabel *labelTaxedTotal = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/2 - margin, 100)];
                    labelTaxedTotal.backgroundColor = [UIColor clearColor];
                    labelTaxedTotal.textAlignment = NSTextAlignmentLeft;
                    labelTaxedTotal.text = @"Total";
                    labelTaxedTotal.numberOfLines = 0;
                    labelTaxedTotal.textColor = TEXT_COLOR;
                    labelTaxedTotal.font = titleFont;
                    [labelTaxedTotal sizeToFit];
                    labelTaxedTotal.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelTaxedTotal];
                    
                    UILabel *labelTaxedTotalPrice = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topY, SCREEN_WIDTH/2 - margin, 100)];
                    labelTaxedTotalPrice.backgroundColor = [UIColor clearColor];
                    labelTaxedTotalPrice.textAlignment = NSTextAlignmentRight;
                    labelTaxedTotalPrice.text = [NSString stringWithFormat:@"INR %@", taxedPrice];
                    labelTaxedTotalPrice.numberOfLines = 0;
                    labelTaxedTotalPrice.textColor = TEXT_COLOR;
                    labelTaxedTotalPrice.font = titleFont;
                    [labelTaxedTotalPrice sizeToFit];
                    labelTaxedTotalPrice.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelTaxedTotalPrice];
                    
                    topY += labelTaxedTotalPrice.frame.size.height;
                    topY += margin;
                    
                    line = [[UIView alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH - margin*2, 1)];
                    line.backgroundColor = [UIColor grayColor];
                    [_myContentView addSubview:line];
                    
                    topY += (margin + 1);
                    
                    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/3 - margin, 100)];
                    labelName.backgroundColor = [UIColor clearColor];
                    labelName.textAlignment = NSTextAlignmentLeft;
                    labelName.text = @"Name";
                    labelName.numberOfLines = 0;
                    labelName.textColor = TEXT_COLOR;
                    labelName.font = titleFont;
                    [labelName sizeToFit];
                    labelName.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelName];
                    
                    UILabel *labelNameValue = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topY, (SCREEN_WIDTH*2)/3 - margin, 100)];
                    labelNameValue.backgroundColor = [UIColor clearColor];
                    labelNameValue.textAlignment = NSTextAlignmentLeft;
                    labelNameValue.text = nameCustomer;
                    labelNameValue.numberOfLines = 0;
                    labelNameValue.textColor = TEXT_COLOR;;
                    labelNameValue.font = titleFont;
                    [labelNameValue sizeToFit];
                    labelNameValue.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelNameValue];
                    
                    topY += labelNameValue.frame.size.height;
                    topY += margin;
                    
                    UILabel *labelEmail = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/3 - margin, 100)];
                    labelEmail.backgroundColor = [UIColor clearColor];
                    labelEmail.textAlignment = NSTextAlignmentLeft;
                    labelEmail.text = @"Email";
                    labelEmail.numberOfLines = 0;
                    labelEmail.textColor = TEXT_COLOR;
                    labelEmail.font = titleFont;
                    [labelEmail sizeToFit];
                    labelEmail.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelEmail];
                    
                    UILabel *labelEmailValue = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topY, (SCREEN_WIDTH*2)/3 - margin, 100)];
                    labelEmailValue.backgroundColor = [UIColor clearColor];
                    labelEmailValue.textAlignment = NSTextAlignmentLeft; // UITextAlignmentCenter,
                    labelEmailValue.text = emailCustomer;
                    labelEmailValue.numberOfLines = 0;
                    labelEmailValue.textColor = TEXT_COLOR;
                    labelEmailValue.font = titleFont;
                    [labelEmailValue sizeToFit];
                    labelEmailValue.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelEmailValue];
                    
                    topY += labelEmailValue.frame.size.height;
                    topY += margin;
                    
                    UILabel *labelPhone = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/3 - margin, 100)];
                    labelPhone.backgroundColor = [UIColor clearColor];
                    labelPhone.textAlignment = NSTextAlignmentLeft;
                    labelPhone.text = @"Phone";
                    labelPhone.numberOfLines = 0;
                    labelPhone.textColor = TEXT_COLOR;
                    labelPhone.font = titleFont;
                    [labelPhone sizeToFit];
                    labelPhone.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelPhone];
                    
                    UILabel *labelPhoneValue = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topY, (SCREEN_WIDTH*2)/3 - margin, 100)];
                    labelPhoneValue.backgroundColor = [UIColor clearColor];
                    labelPhoneValue.textAlignment = NSTextAlignmentLeft;
                    labelPhoneValue.text = phoneCustomer;
                    labelPhoneValue.numberOfLines = 0;
                    labelPhoneValue.textColor = TEXT_COLOR;
                    labelPhoneValue.font = titleFont;
                    [labelPhoneValue sizeToFit];
                    labelPhoneValue.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelPhoneValue];
                    
                    topY += labelPhoneValue.frame.size.height;
                    topY += margin;
                    
                    UILabel *labelAddress = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/3 - margin, 100)];
                    labelAddress.backgroundColor = [UIColor clearColor];
                    labelAddress.textAlignment = NSTextAlignmentLeft;
                    labelAddress.text = @"Shipping Address";
                    labelAddress.numberOfLines = 0;
                    labelAddress.textColor = TEXT_COLOR;
                    labelAddress.font = titleFont;
                    [labelAddress sizeToFit];
                    labelAddress.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelAddress];
                    
                    UILabel *labelAddressValue = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topY, (SCREEN_WIDTH*2)/3 - margin, 100)];
                    labelAddressValue.backgroundColor = [UIColor clearColor];
                    labelAddressValue.textAlignment = NSTextAlignmentLeft;
                    labelAddressValue.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", addressCustomer, city, state, country];
                    labelAddressValue.numberOfLines = 0;
                    labelAddressValue.textColor = TEXT_COLOR;
                    labelAddressValue.font = titleFont;
                    [labelAddressValue sizeToFit];
                    labelAddressValue.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelAddressValue];
                    
                    topY += labelAddressValue.frame.size.height;
                    topY += margin;
                    
                    line = [[UIView alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH - margin*2, 1)];
                    line.backgroundColor = [UIColor grayColor];
                    [_myContentView addSubview:line];
                    
                    topY += (margin + 1);
                    
                    UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/3 - margin, 100)];
                    labelTime.backgroundColor = [UIColor clearColor];
                    labelTime.textAlignment = NSTextAlignmentLeft;
                    labelTime.text = @"Timestamp";
                    labelTime.numberOfLines = 0;
                    labelTime.textColor = TEXT_COLOR;
                    labelTime.font = titleFont;
                    [labelTime sizeToFit];
                    labelTime.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelTime];
                    
                    UILabel *labelTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topY, (SCREEN_WIDTH*2)/3 - margin, 100)];
                    labelTimeValue.backgroundColor = [UIColor clearColor];
                    labelTimeValue.textAlignment = NSTextAlignmentLeft;
                    labelTimeValue.text = timestamp;
                    labelTimeValue.numberOfLines = 0;
                    labelTimeValue.textColor = TEXT_COLOR;
                    labelTimeValue.font = titleFont;
                    [labelTimeValue sizeToFit];
                    labelTimeValue.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelTimeValue];
                    
                    topY += labelTimeValue.frame.size.height;
                    topY += margin;
                    
                    UILabel *labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, SCREEN_WIDTH/3 - margin, 100)];
                    labelStatus.backgroundColor = [UIColor clearColor];
                    labelStatus.textAlignment = NSTextAlignmentLeft;
                    labelStatus.text = @"Status";
                    labelStatus.numberOfLines = 0;
                    labelStatus.textColor = TEXT_COLOR;
                    labelStatus.font = titleFont;
                    [labelStatus sizeToFit];
                    labelStatus.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelStatus];
                    
                    UILabel *labelStatusValue = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, topY, (SCREEN_WIDTH*2)/3 - margin, 100)];
                    labelStatusValue.backgroundColor = [UIColor clearColor];
                    labelStatusValue.textAlignment = NSTextAlignmentLeft; // UITextAlignmentCenter,
                    labelStatusValue.text = status;
                    labelStatusValue.numberOfLines = 0;
                    labelStatusValue.textColor = TEXT_COLOR;
                    labelStatusValue.font = titleFont;
                    [labelStatusValue sizeToFit];
                    labelStatusValue.lineBreakMode = NSLineBreakByWordWrapping;
                    [_myContentView addSubview:labelStatusValue];
                    
                    topY += labelStatusValue.frame.size.height;
                    topY += margin;
                    
                    _scView.contentSize = CGSizeMake(SCREEN_WIDTH, topY);
                    
                }
                
            } else {
                
                UIAlertView *alertNoOrders = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                             message:@"No orders yet!"
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil, nil];
                [alertNoOrders show];
                
            }
            
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Error=%@", error.description);
    [self initiateDownload];
}

- (void)handleLoadMore:(UITapGestureRecognizer *)recognizer {
    
    [self initiateDownload];
    
}

@end
