//
//  ConfirmCollectionViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 28/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "NavigationViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "AppDelegate.h"
#import "SyncViewController.h"
#import "ConfirmCollectionViewCell.h"
#import "ConfirmFooterCollectionReusableView.h"
#import "ConfirmHeaderCollectionReusableView.h"
#import "CheckoutTableViewController.h"
#import "CouponRecord.h"
#import "TaxRecord.h"
#import "ConfirmCollectionViewController.h"
#import "PoliciesListCollectionViewController.h"
#import "PaymentViewController.h"

@interface ConfirmCollectionViewController ()

@end

@implementation ConfirmCollectionViewController

static NSString * const reuseIdentifier = @"ConfirmCell";

@synthesize connDownloadCart = _connDownloadCart;
@synthesize connOrderNew = _connOrderNew;
@synthesize responseData = _responseData;
@synthesize arrQuantities = _arrQuantities;
@synthesize arrDiscountedPrices = _arrDiscountedPrices;
@synthesize arrBookingPrices = _arrBookingPrices;
@synthesize arrIdStreams = _arrIdStreams;
@synthesize arrWeights = _arrWeights;
@synthesize arrIdItems = _arrIdItems;
@synthesize arrPrices = _arrPrices;
@synthesize arrIdCart = _arrIdCart;
@synthesize arrTitles = _arrTitles;
@synthesize arrPictures = _arrPictures;
@synthesize arrDiscountCodes = _arrDiscountCodes;
@synthesize arrDiscountTypes = _arrDiscountTypes;
@synthesize arrDiscountValues = _arrDiscountValues;
@synthesize tax1Value = _tax1Value;
@synthesize tax1Label = _tax1Label;
@synthesize pgPostData = _pgPostData;
@synthesize alertCheckInternet = _alertCheckInternet;
@synthesize alertConfirmRemove = _alertConfirmRemove;
@synthesize nav = _nav;
@synthesize cellMoney = _cellMoney;
@synthesize cellShipping = _cellShipping;
@synthesize billingName = _billingName;
@synthesize billingPhone = _billingPhone;
@synthesize billingAddress = _billingAddress;
@synthesize billingPincode = _billingPincode;
@synthesize subTotal = _subTotal;
@synthesize totalAfterTaxes = _totalAfterTaxes;
@synthesize totalAfterCoupon = _totalAfterCoupon;
@synthesize containsBooking = _containsBooking;
@synthesize containsDiscount = _containsDiscount;

int alertConfirmRemoveIndex = -1;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _billingName = @"";
    _billingAddress = @"";
    _billingPhone = @"";
    _billingPincode = @"";
    
    _nav = (NavigationViewController *)self.navigationController;
}

- (void) viewDidAppear:(BOOL)animated {
    
    IS_OPENED_FROM_CART = true;
    self.navigationItem.title = @"Confirm";
    [self loadFromDb];
    
    
    
}

- (void) viewDidDisappear:(BOOL)animated {
    IS_OPENED_FROM_CART = false;
}

- (void) loadFromDb {
    
    alertConfirmRemoveIndex = -1;
    
    _arrIdItems = [[NSMutableArray alloc] init];
    _arrIdCart = [[NSMutableArray alloc] init];
    _arrWeights = [[NSMutableArray alloc] init];
    _arrIdStreams = [[NSMutableArray alloc] init];
    _arrTitles = [[NSMutableArray alloc] init];
    _arrQuantities = [[NSMutableArray alloc] init];
    _arrPrices = [[NSMutableArray alloc] init];
    _arrDiscountedPrices = [[NSMutableArray alloc] init];
    _arrDiscountCodes = [[NSMutableArray alloc] init];
    _arrDiscountTypes = [[NSMutableArray alloc] init];
    _arrDiscountValues = [[NSMutableArray alloc] init];
    _arrBookingPrices = [[NSMutableArray alloc] init];
    _arrPrices = [[NSMutableArray alloc] init];
    _arrPictures = [[NSMutableArray alloc] init];
    
    if([_nav isNetworkAvailable]) {
        
        [_nav setCartBadgeByCountingCartItems];
        
        if(MY_CITYID.length > 0) {
            
            // Get open cart
            
            NSDictionary *map = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_CART,
                                  DB_COL_CART_ISOPEN: DB_RECORD_VALUE_CART_OPEN
                                  };
            NSString *_idOpenCart = @"";
            _idOpenCart = [[DbHelper getSharedInstance] retrieve_id:map];
            
            // If open cart exists proceed else show message no item present
            
            if(_idOpenCart == Nil || _idOpenCart.length == 0) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                message:@"Cart is empty!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                [_nav popViewControllerAnimated:YES];
                
                
            } else {
                
                map = @{
                        DB_COL_TYPE: DB_RECORD_TYPE_CART_ITEM,
                        DB_COL_FOREIGN_KEY: _idOpenCart
                        };
                NSMutableArray *recordsItems = [[DbHelper getSharedInstance] retrieveRecords:map];
                
                if(recordsItems.count <= 0) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:@"Cart is empty!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    [_nav popViewControllerAnimated:YES];
                    
                } else {
                    
                    NSString *jsonStr = [NSString stringWithFormat:@"[{\"idProject\": \"%@\", \"idCountry\": \"%@\", \"idState\": \"%@\", \"idCity\": \"%@\", \"numItems\": \"%d\", \"items\": [", PID, MY_COUNTRYID, MY_STATEID, MY_CITYID, recordsItems.count];
                    
                    for(int i = 0; i < recordsItems.count; i++) {
                        
                        map = [recordsItems objectAtIndex:i];
                        NSString *idStream = [map objectForKey:DB_COL_CART_ITEM_STREAM_ID];
                        NSString *idItem = [map objectForKey:DB_COL_CART_ITEM_ITEM_ID];
                        if(i == (recordsItems.count - 1)) {
                            jsonStr = [NSString stringWithFormat:@"%@{\"stream\": \"%@\", \"item\": \"%@\"}", jsonStr, idStream, idItem];
                        } else {
                            jsonStr = [NSString stringWithFormat:@"%@{\"stream\": \"%@\", \"item\": \"%@\"}, ", jsonStr, idStream, idItem];
                        }
                        
                    }
                    
                    jsonStr = [NSString stringWithFormat:@"%@]}]", jsonStr];
                    
                    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_CART];
                    NSString *myRequestString = [NSString stringWithFormat:@"params=%@", jsonStr];
                    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
                    [ request setHTTPMethod: @"POST" ];
                    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
                    [ request setHTTPBody: myRequestData ];
                    
                    _connDownloadCart = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                    
                }
                
            }
        }
        
        
    } else {
        
        _alertCheckInternet = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"You are not connected to the Internet!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [_alertCheckInternet show];
        [_nav popViewControllerAnimated:YES];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (void)dealloc {
    
    self.collectionView = nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_arrIdCart.count > 0) {
        return (_arrIdCart.count + 2);
    } else {
        return 0;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        ConfirmHeaderCollectionReusableView *headerView = (ConfirmHeaderCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ConfirmHeader" forIndexPath:indexPath];
        
        headerView.textHead.font = [UIFont systemFontOfSize:FONT_SIZE_LIST_TITLES];
        
        return headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        
        ConfirmFooterCollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ConfirmFooter" forIndexPath:indexPath];
        
        UITapGestureRecognizer *tapNextRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnNext:)];
        tapNextRecognizer.numberOfTapsRequired = 1;
        [footerview.textButton addGestureRecognizer:tapNextRecognizer];
        footerview.textButton.userInteractionEnabled = YES;
        footerview.textButton.font = [UIFont systemFontOfSize:FONT_SIZE_ACTION_BUTTON];
        
        return footerview;
    }
    
    return reusableview;
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] < (_arrTitles.count)) {
        
        return CGSizeMake(SCREEN_WIDTH, 125);
        
    } else if([indexPath row] == (_arrTitles.count)) {
        
        return CGSizeMake(SCREEN_WIDTH, 128);
        
    } else {
        
        return CGSizeMake(SCREEN_WIDTH, 300);
        
    }
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] < (_arrTitles.count)) {
        
        ConfirmCollectionViewCell *cellCart = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        if(_arrTitles.count > 0) {
            
            cellCart.textTitle.text = [_arrTitles objectAtIndex:[indexPath row]];
            cellCart.fieldQuantity.text = [_arrQuantities objectAtIndex:[indexPath row]];
            cellCart.fieldQuantity.delegate = self;
            [cellCart.fieldQuantity setEnabled:FALSE];
            
            cellCart.textPrice.text = [NSString stringWithFormat:@"INR %@", [_arrPrices objectAtIndex:[indexPath row]]];
            
            NSString *discountedPrice = [_arrDiscountedPrices objectAtIndex:[indexPath row]];
            if(discountedPrice.length == 0) {
                [cellCart.textDiscount setHidden:YES];
            } else {
                [cellCart.textDiscount setHidden:NO];
                cellCart.textDiscount.text = [NSString stringWithFormat:@"INR %@", discountedPrice];
                
                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:cellCart.textPrice.text];
                [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                        value:@2
                                        range:NSMakeRange(0, [attributeString length])];
                cellCart.textPrice.attributedText = attributeString;
                
            }
            
            NSString *bookingPrice = [_arrBookingPrices objectAtIndex:[indexPath row]];
            if(bookingPrice.length == 0) {
                [cellCart.textBooking setHidden:YES];
            } else {
                [cellCart.textBooking setHidden:NO];
                cellCart.textBooking.text = [NSString stringWithFormat:@"Booking: INR %@", bookingPrice];
            }
            
            cellCart.fieldQuantity.tag = [indexPath row];
            
            NSString *picture = [_arrPictures objectAtIndex: [indexPath row]];
            picture = [picture stringByReplacingOccurrencesOfString: @"http" withString:@"https"];
            
            if(picture.length > 0) {
                
                NSURL *url = [NSURL URLWithString:picture];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                 {
                     
                     if(error == nil) {
                         
                         UIImage *original=[UIImage imageWithData:data];
                         UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:0.1 orientation:original.imageOrientation];
                         cellCart.pictureProduct.image=small;
                         
                     }
                     
                 }];
            }
            
        }
        
        return cellCart;
        
    } else if([indexPath row] == _arrTitles.count) {
        
        _cellMoney = [collectionView dequeueReusableCellWithReuseIdentifier:@"ConfirmMoney" forIndexPath:indexPath];
        
        _cellMoney.textSubtotal.text = [NSString stringWithFormat:@"INR %.2f", _subTotal];
        _cellMoney.textCouponTotal.text = [NSString stringWithFormat:@"INR %.2f", _totalAfterCoupon];
        
        CouponRecord *cr = [_nav getCouponAppliedToCart];
        if(cr == nil) {
            [_cellMoney.textCouponTotal setHidden:YES];
            [_cellMoney.textCouponLabel setHidden:YES];
        } else {
            [_cellMoney.textCouponTotal setHidden:NO];
            [_cellMoney.textCouponLabel setHidden:NO];
        }
        
        if(_tax1Value.length > 0) {
            
            _cellMoney.textTaxes.text = _tax1Value;
            _cellMoney.textTaxesLabel.text = [_tax1Label uppercaseString];
            [_cellMoney.textTaxes setHidden:NO];
            [_cellMoney.textTaxes setHidden:NO];
            
        } else {
            
            [_cellMoney.textTaxes setHidden:YES];
            [_cellMoney.textTaxesLabel setHidden:YES];
            
        }
        
        _cellMoney.textTaxesTotal.text = [NSString stringWithFormat:@"INR %.2f", _totalAfterTaxes];
        
        return _cellMoney;
        
    } else {
        
        _cellShipping = [collectionView dequeueReusableCellWithReuseIdentifier:@"ConfirmShipping" forIndexPath:indexPath];
        
        NSDictionary *cvEmail = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                                  };
        NSMutableArray *arrEmail = [[DbHelper getSharedInstance] retrieveRecords:cvEmail];
        if(arrEmail.count > 0) {
            cvEmail = [arrEmail objectAtIndex:0];
            _cellShipping.textEmail.text = [NSString stringWithFormat:@"Email: %@", [cvEmail objectForKey:DB_COL_EMAIL]];
        }
        
        NSDictionary *cvName = @{
                                 DB_COL_TYPE: DB_RECORD_TYPE_MY_NAME
                                 };
        NSMutableArray *arrNames = [[DbHelper getSharedInstance] retrieveRecords:cvName];
        if(arrNames.count > 0) {
            cvName = [arrNames objectAtIndex:0];
            _cellShipping.textName.text = [NSString stringWithFormat:@"Name: %@", [cvName objectForKey:DB_COL_NAME]];
            _billingName = [cvName objectForKey:DB_COL_NAME];
        }
        
        NSDictionary *cvAddress = @{
                                    DB_COL_TYPE: DB_RECORD_TYPE_MY_ADDRESS
                                    };
        NSMutableArray *arrAddresses = [[DbHelper getSharedInstance] retrieveRecords:cvAddress];
        if(arrAddresses.count > 0) {
            cvAddress = [arrAddresses objectAtIndex:0];
            _cellShipping.textAddress.text = [NSString stringWithFormat:@"Address: %@", [cvAddress objectForKey:DB_COL_CONTENT]];
            _billingAddress = [cvAddress objectForKey:DB_COL_CONTENT];
        }
        
        NSDictionary *cvPhone = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_MY_PHONE
                                  };
        
        NSMutableArray *arrPhone = [[DbHelper getSharedInstance] retrieveRecords:cvPhone];
        if(arrPhone.count > 0) {
            cvPhone = [arrPhone objectAtIndex:0];
            _cellShipping.textPhone.text = [NSString stringWithFormat:@"Phone: %@", [cvPhone objectForKey:DB_COL_PHONE]];
            _billingPhone = [cvPhone objectForKey:DB_COL_PHONE];
        }
        
        NSDictionary *cvPincode = @{
                                    DB_COL_TYPE: DB_RECORD_TYPE_MY_PINCODE
                                    };
        NSMutableArray *arrPincode = [[DbHelper getSharedInstance] retrieveRecords:cvPincode];
        if(arrPincode.count > 0) {
            cvPincode = [arrPincode objectAtIndex:0];
            _cellShipping.textPincode.text = [NSString stringWithFormat:@"Pincode: %@", [cvPincode objectForKey:DB_COL_TITLE]];
            _billingPincode = [cvPincode objectForKey:DB_COL_TITLE];
        }
        
        _cellShipping.textCountry.text = [NSString stringWithFormat:@"Country: %@", MY_COUNTRYNAME];
        _cellShipping.textState.text = [NSString stringWithFormat:@"State: %@", MY_STATENAME];
        _cellShipping.textCity.text = [NSString stringWithFormat:@"City: %@", MY_CITYNAME];
        
        UITapGestureRecognizer *tapTermsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnTerms:)];
        tapTermsRecognizer.numberOfTapsRequired = 1;
        [_cellShipping.textTerms addGestureRecognizer:tapTermsRecognizer];
        _cellShipping.textTerms.userInteractionEnabled = YES;
        _cellShipping.textTerms.tag = [indexPath row];
        
        return _cellShipping;
        
    }
    
}


- (NSString *)urlencode: (NSString *)str{
    NSMutableString *output = [NSMutableString string];
    const char *source = [str cStringUsingEncoding:NSUTF8StringEncoding];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '&'){
            [output appendString:@"and"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
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
    
    if(connection == _connOrderNew) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {

            NSString *value = [json objectForKey:@"value"];
            _pgPostData = [NSString stringWithFormat:@"channel=10"];
            _pgPostData = [NSString stringWithFormat:@"%@&account_id=%@", _pgPostData, PG_MERCHANT_ID];
            _pgPostData = [NSString stringWithFormat:@"%@&reference_no=%@", _pgPostData, value];
            _pgPostData = [NSString stringWithFormat:@"%@&mode=LIVE", _pgPostData];
            _pgPostData = [NSString stringWithFormat:@"%@&currency=INR", _pgPostData];
            _pgPostData = [NSString stringWithFormat:@"%@&description=INR", _pgPostData];
            _pgPostData = [NSString stringWithFormat:@"%@&return_url=%@", _pgPostData, [self urlencode:PG_REDIRECT_URL]];
            _pgPostData = [NSString stringWithFormat:@"%@&name=%@", _pgPostData, [self urlencode:_billingName]];
            _pgPostData = [NSString stringWithFormat:@"%@&address=%@", _pgPostData, [self urlencode:_billingAddress]];
            _pgPostData = [NSString stringWithFormat:@"%@&city=%@", _pgPostData, [self urlencode:MY_CITYNAME]];
            _pgPostData = [NSString stringWithFormat:@"%@&state=%@", _pgPostData, [self urlencode:MY_STATENAME]];
            _pgPostData = [NSString stringWithFormat:@"%@&country=IND", _pgPostData];
            _pgPostData = [NSString stringWithFormat:@"%@&postal_code=%@", _pgPostData, [self urlencode:_billingPincode]];
            _pgPostData = [NSString stringWithFormat:@"%@&phone=%@", _pgPostData, [self urlencode:_billingPhone]];
            _pgPostData = [NSString stringWithFormat:@"%@&email=%@", _pgPostData, [self urlencode:MY_EMAIL]];
            
            NSLog(@"PGURL=%@", _pgPostData);
            
            PaymentViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PaymentContainer"];
            vc.paymentGatewayPost = _pgPostData;
            vc.idOrder = value;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Cannot place order! Try again later"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
    } else if(connection == _connDownloadCart) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            NSString *_idOpenCart = @"";
            NSDictionary *map = @{
                                  DB_COL_TYPE: DB_RECORD_TYPE_CART,
                                  DB_COL_CART_ISOPEN: DB_RECORD_VALUE_CART_OPEN
                                  };
            NSMutableArray *recordsOpenCart = [[DbHelper getSharedInstance] retrieveRecords:map];
            
            if(recordsOpenCart.count > 0) {
                
                // Open Cart Exists so retrieve its handle
                
                map = [recordsOpenCart objectAtIndex:0];
                _idOpenCart = [map objectForKey:DB_COL_ID];
                
                map = @{
                        DB_COL_TYPE: DB_RECORD_TYPE_CART_ITEM,
                        DB_COL_FOREIGN_KEY: _idOpenCart
                        };
                NSMutableArray *recordsItemInCart = [[DbHelper getSharedInstance] retrieveRecords:map];
                
                
                NSString* value = [json objectForKey:@"value"];
                NSData *dataValue = [value dataUsingEncoding:NSUTF8StringEncoding];
                json = [NSJSONSerialization
                        JSONObjectWithData:dataValue //1
                        options:kNilOptions
                        error:&error];
                
                NSMutableArray *jsonArr = (NSMutableArray *)[NSJSONSerialization
                                                             JSONObjectWithData:dataValue //1
                                                             options:kNilOptions
                                                             error:&error];
                
                _arrIdCart = [[NSMutableArray alloc] init];
                _arrWeights = [[NSMutableArray alloc] init];
                _arrTitles = [[NSMutableArray alloc] init];
                _arrQuantities = [[NSMutableArray alloc] init];
                _arrPrices = [[NSMutableArray alloc] init];
                _arrDiscountedPrices = [[NSMutableArray alloc] init];
                _arrBookingPrices = [[NSMutableArray alloc] init];
                _arrPrices = [[NSMutableArray alloc] init];
                _arrPictures = [[NSMutableArray alloc] init];
                
                _containsDiscount = false;
                
                for(int i = 0; i < jsonArr.count; i++) {
                    
                    json = [jsonArr objectAtIndex:i];
                    map = [recordsItemInCart objectAtIndex:i];
                    
                    NSMutableArray *jsonArrItems = [json objectForKey:@"info"];
                    NSMutableArray *jsonArrPictures = [json objectForKey:@"pictures"];
                    
                    NSString *priceMapped = [json objectForKey:@"price"];
                    
                    json = [jsonArrItems objectAtIndex:0];
                    NSString *title = [json objectForKey:@"title"];
                    NSString *priceItem = [json objectForKey:@"price"];
                    NSString *booking = [json objectForKey:@"bookingPrice"];
                    NSString *quantity = [map objectForKey:DB_COL_CART_ITEM_QUANTITY];
                    NSString *discount = [map objectForKey:DB_COL_DISCOUNT];
                    
                    if(booking.length > 0) {
                        _containsBooking = YES;
                    } else {
                        _containsBooking = NO;
                    }
                    
                    if([priceMapped integerValue] == -1) {
                    } else {
                        priceItem = priceMapped;
                    }
                    
                    CGFloat priceF = [priceItem floatValue];
                    int quantityI = [quantity integerValue];
                    CGFloat costF = priceF * quantityI;
                    
                    NSString *discountedPrice = @"";
                    NSString *discountCode = @"";
                    NSString *discountType = @"";
                    NSString *discountValue = @"";
                    
                    if([_nav getDiscount:discount] != nil) {
                        
                        _containsDiscount = YES;
                        
                        NSDictionary *cv = [_nav getDiscount:discount];
                        NSString *type = [cv objectForKey:DB_COL_TITLE];
                        NSString *value = [cv objectForKey:DB_COL_PRICE];
                        CGFloat valueF = [value floatValue];
                        discountCode = [cv objectForKey:DB_COL_NAME];
                        discountType = type;
                        discountValue = value;
                        
                        CGFloat discountedPriceF = 0;
                        if([type isEqualToString:DB_DISCOUNT_TYPE_PERCENTAGE]) {
                            
                            discountedPriceF = costF - ((costF*valueF)/100);
                            
                        } else {
                            
                            discountedPriceF = priceF - valueF;
                            
                        }
                        
                        discountedPrice = [NSString stringWithFormat:@"%.2f", discountedPriceF];
                        
                    }
                    
                    [_arrTitles addObject:title];
                    [_arrQuantities addObject:quantity];
                    [_arrPrices addObject:[NSString stringWithFormat:@"%.2f", costF]];
                    [_arrIdCart addObject:[map objectForKey:DB_COL_ID]];
                    [_arrBookingPrices addObject:booking];
                    [_arrDiscountedPrices addObject:discountedPrice];
                    [_arrDiscountCodes addObject:discountCode];
                    [_arrDiscountTypes addObject:discountType];
                    [_arrDiscountValues addObject:discountValue];
                    
                    if(jsonArrPictures.count > 0) {
                        
                        NSDictionary *jsonObjPict = [jsonArrPictures objectAtIndex:0];
                        NSString *pathPicture = [jsonObjPict objectForKey:@"pathThumbnail"];
                        [_arrPictures addObject:pathPicture];
                        
                    }
                    
                }
                
                _subTotal = 0;
                _totalAfterCoupon = 0;
                
                // Calculate Price before Coupons
                
                for(int i = 0; i < _arrPrices.count; i++) {
                    
                    NSString *bookingPrice = [_arrBookingPrices objectAtIndex:i];
                    
                    if(bookingPrice.length > 0) {
                        
                        _subTotal += [bookingPrice floatValue];
                        
                    } else {
                        
                        NSString *discountedPrice = [_arrDiscountedPrices objectAtIndex:i];
                        if(discountedPrice.length > 0) {
                            
                            _subTotal += [discountedPrice floatValue];
                            
                        } else {
                            
                            NSString *price = [_arrPrices objectAtIndex:i];
                            _subTotal += [price floatValue];
                            
                        }
                        
                    }
                    
                }
                
                CouponRecord *cr = [_nav getCouponAppliedToCart];
                if(cr == nil) {
                    _totalAfterCoupon = _subTotal;
                } else {
                    
                    NSString *type = cr.type;
                    NSString *value = cr.value;
                    CGFloat valueF = [value floatValue];
                    
                    CGFloat couponedPriceF = 0;
                    
                    if([type isEqualToString:DB_DISCOUNT_TYPE_PERCENTAGE]) {
                        
                        couponedPriceF = _subTotal - ((_subTotal*valueF)/100);
                        
                    } else {
                        
                        couponedPriceF = _subTotal - valueF;
                        
                    }
                    
                    _totalAfterCoupon = [[NSString stringWithFormat:@"%.2f", couponedPriceF] floatValue];
                    
                }
                
                TaxRecord *record = [_nav getTax1];
                if(record != Nil) {
                    _tax1Label = record.label;
                    _tax1Value = [NSString stringWithFormat:@"%@%%", record.value];
                    _totalAfterTaxes = _totalAfterCoupon + ((_totalAfterCoupon*[_tax1Value floatValue])/100);
                } else {
                    _tax1Label = @"";
                    _tax1Value = @"";
                    _totalAfterTaxes = _totalAfterCoupon;
                }
                [self.collectionView reloadData];
                
            }
            
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    if(connection == _connOrderNew) {
        
        [self callOrderNew];
        
    } else {
        
        [self viewDidLoad];
        [self viewDidAppear:YES];
        
    }
    
    
}

- (void) userTappedOnTerms:(UIGestureRecognizer*)gestureRecognizer; {
    
    PoliciesListCollectionViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PoliciesListContainer"];
    [self.navigationController pushViewController:vc animated:YES];

    
}

- (void) callOrderNew {
    
    NSString *discountCode = @"";
    NSString *discountValue = @"";
    NSString *discountType = @"";
    
    CouponRecord *cr = [_nav getCouponAppliedToCart];
    if(cr != Nil) {
        discountCode = cr.code;
        discountType = cr.type;
        discountValue = cr.value;
    }
    
    NSString *jsonStr = @"";
    
    TaxRecord *record = [_nav getTax1];
    if(record != Nil) {
        jsonStr = [NSString stringWithFormat:@"%@[{\"idProject\": \"%@\", \"email\": \"%@\", \"token\": \"%@\", \"nameCustomer\": \"%@\", \"phoneCustomer\": \"%@\", \"address\": \"%@\", \"country\": \"%@\", \"state\": \"%@\", \"city\": \"%@\", \"pincode\": \"%@\", \"modePayment\": \"online\", \"price\": \"%.2f\", \"priceOriginal\": \"%.2f\", \"discountCode\": \"%@\", \"discountType\": \"%@\", \"discountValue\": \"%@\", \"numItems\": \"%d\", \"taxLabel1\": \"%@\", \"taxValue1\": \"%@\", \"taxLabel2\": \"\", \"taxValue2\": \"\", \"taxLabel3\": \"\", \"taxValue3\": \"\", \"taxedPrice\": \"%.2f\", \"items\": [", jsonStr, PID, MY_EMAIL, MY_TOKEN, _billingName, _billingPhone, _billingAddress, MY_COUNTRYNAME, MY_STATENAME, MY_CITYNAME, _billingPincode, _totalAfterCoupon, _subTotal, discountCode, discountType, discountValue, _arrIdCart.count, record.label, record.value, _totalAfterTaxes];
    } else {
        jsonStr = [NSString stringWithFormat:@"%@[{\"idProject\": \"%@\", \"email\": \"%@\", \"token\": \"%@\", \"nameCustomer\": \"%@\", \"phoneCustomer\": \"%@\", \"address\": \"%@\", \"country\": \"%@\", \"state\": \"%@\", \"city\": \"%@\", \"pincode\": \"%@\", \"modePayment\": \"online\", \"price\": \"%.2f\", \"priceOriginal\": \"%.2f\", \"discountCode\": \"%@\", \"discountType\": \"%@\", \"discountValue\": \"%@\", \"numItems\": \"%d\", \"taxLabel1\": \"\", \"taxValue1\": \"\", \"taxLabel2\": \"\", \"taxValue2\": \"\", \"taxLabel3\": \"\", \"taxValue3\": \"\", \"taxedPrice\": \"%.2f\", \"items\": [", jsonStr, PID, MY_EMAIL, MY_TOKEN, _billingName, _billingPhone, _billingAddress, MY_COUNTRYNAME, MY_STATENAME, MY_CITYNAME, _billingPincode, _totalAfterCoupon, _subTotal, discountCode, discountType, discountValue, _arrIdCart.count, _totalAfterTaxes];
    }
    
    for(int i = 0; i < _arrIdCart.count; i++) {
        
        jsonStr = [NSString stringWithFormat:@"%@{", jsonStr];
        NSString *discountedPrice = [_arrDiscountedPrices objectAtIndex:i];
        NSString *price = [_arrPrices objectAtIndex:i];
        NSString *booking = [_arrBookingPrices objectAtIndex:i];
        
        jsonStr = [NSString stringWithFormat:@"%@\"nameItem\": \"%@\",", jsonStr, [_arrTitles objectAtIndex:i]];
        jsonStr = [NSString stringWithFormat:@"%@\"qItem\": \"%@\",", jsonStr, [_arrQuantities objectAtIndex:i]];
        if(discountedPrice.length == 0) {
            jsonStr = [NSString stringWithFormat:@"%@\"priceItem\": \"%@\",", jsonStr, price];
        } else {
            jsonStr = [NSString stringWithFormat:@"%@\"priceItem\": \"%@\",", jsonStr, discountedPrice];
        }
        jsonStr = [NSString stringWithFormat:@"%@\"bookingPrice\": \"%@\",", jsonStr, booking];
        jsonStr = [NSString stringWithFormat:@"%@\"priceOriginal\": \"%@\",", jsonStr, price];
        jsonStr = [NSString stringWithFormat:@"%@\"discountCode\": \"%@\",", jsonStr, [_arrDiscountCodes objectAtIndex:i]];
        jsonStr = [NSString stringWithFormat:@"%@\"discountValue\": \"%@\",", jsonStr, [_arrDiscountValues objectAtIndex:i]];
        jsonStr = [NSString stringWithFormat:@"%@\"discountType\": \"%@\"", jsonStr, [_arrDiscountTypes objectAtIndex:i]];
        
        if(i == (_arrIdCart.count - 1)) {
            jsonStr = [NSString stringWithFormat:@"%@}", jsonStr];
        } else {
            jsonStr = [NSString stringWithFormat:@"%@},", jsonStr];
        }
        
    }
    jsonStr = [NSString stringWithFormat:@"%@]}]", jsonStr];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_ORDER_NEW];
    NSString *myRequestString = [NSString stringWithFormat:@"params=%@", jsonStr];
    NSLog(@"Request Params = %@", jsonStr);
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connOrderNew = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}


- (void) userTappedOnNext:(UIGestureRecognizer*)gestureRecognizer; {
    
    [self callOrderNew];
    
}

@end
