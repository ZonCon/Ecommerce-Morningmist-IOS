//
//  CartCollectionViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 22/01/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "NavigationViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "AppDelegate.h"
#import "SyncViewController.h"
#import "CartCollectionViewCell.h"
#import "CartCollectionViewController.h"
#import "CartCouponCollectionViewCell.h"
#import "CartMoneyCollectionViewCell.h"
#import "CartFooterCollectionReusableView.h"
#import "CartHeaderCollectionReusableView.h"
#import "CheckoutTableViewController.h"
#import "CouponRecord.h"
#import "TaxRecord.h"

@interface CartCollectionViewController ()

@end

@implementation CartCollectionViewController

@synthesize connDownloadCart = _connDownloadCart;
@synthesize connValidateCoupon = _connValidateCoupon;
@synthesize responseData = _responseData;

@synthesize arrPictures = _arrPictures;
@synthesize arrTitles = _arrTitles;
@synthesize arrIdCart = _arrIdCart;
@synthesize arrPrices = _arrPrices;
@synthesize arrIdItems = _arrIdItems;
@synthesize arrIdStreams = _arrIdStreams;
@synthesize arrBookingPrices = _arrBookingPrices;
@synthesize arrDiscountedPrices = _arrDiscountedPrices;
@synthesize arrQuantities = _arrQuantities;
@synthesize tax1Label = _tax1Label;
@synthesize tax1Value = _tax1Value;
@synthesize nav = _nav;
@synthesize alertCheckInternet = _alertCheckInternet;
@synthesize alertConfirmRemove = _alertConfirmRemove;

static NSString * const reuseIdentifier = @"CartCell";

CartMoneyCollectionViewCell *cellMoney;
CartCouponCollectionViewCell *cellCoupon;

int alertRemoveIndex = -1;
CGFloat subTotal;
CGFloat totalAfterCoupon;
CGFloat totalAfterTaxes;
Boolean containsBooking;
Boolean containsDiscount;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nav = (NavigationViewController *)self.navigationController;
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    IS_OPENED_FROM_CART = true;
    [_nav removeAppliedCouponToCart];
    [self loadFromDb];
    
}

- (void) viewDidDisappear:(BOOL)animated {
    IS_OPENED_FROM_CART = false;
}

- (void) loadFromDb {
    
    alertRemoveIndex = -1;
    
    _arrIdItems = [[NSMutableArray alloc] init];
    _arrIdCart = [[NSMutableArray alloc] init];
    _arrIdStreams = [[NSMutableArray alloc] init];
    _arrTitles = [[NSMutableArray alloc] init];
    _arrQuantities = [[NSMutableArray alloc] init];
    _arrPrices = [[NSMutableArray alloc] init];
    _arrDiscountedPrices = [[NSMutableArray alloc] init];
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
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:15.0];
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
        CartHeaderCollectionReusableView *headerView = (CartHeaderCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CartHeader" forIndexPath:indexPath];
        return headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        CartFooterCollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CartFooter" forIndexPath:indexPath];
        
        UITapGestureRecognizer *tapNextRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnNext:)];
        tapNextRecognizer.numberOfTapsRequired = 1;
        [footerview.textButton addGestureRecognizer:tapNextRecognizer];
        footerview.textButton.userInteractionEnabled = YES;
        
        return footerview;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] < (_arrTitles.count)) {
        
        return CGSizeMake(SCREEN_WIDTH, 125);
        
    } else if([indexPath row] == (_arrTitles.count)) {
        
        return CGSizeMake(SCREEN_WIDTH, 70);
        
    } else {
        
        return CGSizeMake(SCREEN_WIDTH, 128);
        
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] < (_arrTitles.count)) {
        
        CartCollectionViewCell *cellCart = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        if(_arrTitles.count > 0 && _arrQuantities.count > 0) {
            
            cellCart.textTitle.text = [_arrTitles objectAtIndex:[indexPath row]];
            cellCart.fieldQuantity.text = [_arrQuantities objectAtIndex:[indexPath row]];
            cellCart.fieldQuantity.delegate = self;
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
            
            UITapGestureRecognizer *tapRemoveRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnRemove:)];
            tapRemoveRecognizer.numberOfTapsRequired = 1;
            [cellCart.textRemove addGestureRecognizer:tapRemoveRecognizer];
            cellCart.textRemove.userInteractionEnabled = YES;
            cellCart.textRemove.tag = [indexPath row];

            cellCart.fieldQuantity.tag = [indexPath row];
            [cellCart.fieldQuantity addTarget:self
                                       action:@selector(changeQuantity:)
                             forControlEvents:UIControlEventEditingChanged];
            
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
        
    } else if([indexPath row] == (_arrTitles.count)) {
        
        cellCoupon = [collectionView dequeueReusableCellWithReuseIdentifier:@"CartCoupon" forIndexPath:indexPath];
        
        UITapGestureRecognizer *tapApplyCouponRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnApplyCoupon:)];
        tapApplyCouponRecognizer.numberOfTapsRequired = 1;
        [cellCoupon.textApple addGestureRecognizer:tapApplyCouponRecognizer];
        cellCoupon.textApple.userInteractionEnabled = YES;
        
        CouponRecord *cr = [_nav getCouponAppliedToCart];
        if(cr != nil) {
            cellCoupon.fieldCoupon.text = cr.code;
            cellCoupon.textApple.text = @"REMOVE";
            [cellCoupon.textApple setBackgroundColor:[UIColor redColor]];
            [cellCoupon.fieldCoupon setBackgroundColor:TEXT_COLOR];
            cellCoupon.fieldCoupon.textColor = TEXT_COLOR;
        } else {
            cellCoupon.fieldCoupon.text = @"";
            cellCoupon.textApple.text = @"APPLY";
            [cellCoupon.textApple setBackgroundColor:[UIColor colorWithRed:(42.0/255.0) green:(122.0/255.0) blue:(79.0/255.0) alpha:1.0]];
            [cellCoupon.fieldCoupon setBackgroundColor:[UIColor whiteColor  ]];
            cellCoupon.fieldCoupon.textColor = [UIColor blackColor];
        }
        
        
        return cellCoupon;
        
    } else {
        
        cellMoney = [collectionView dequeueReusableCellWithReuseIdentifier:@"CartMoney" forIndexPath:indexPath];
        
        cellMoney.textSubtotal.text = [NSString stringWithFormat:@"INR %.2f", subTotal];
        cellMoney.textCouponTotal.text = [NSString stringWithFormat:@"INR %.2f", totalAfterCoupon];
        
        CouponRecord *cr = [_nav getCouponAppliedToCart];
        if(cr == nil) {
            [cellMoney.textCouponTotal setHidden:YES];
            [cellMoney.textCouponLabel setHidden:YES];
        } else {
            [cellMoney.textCouponTotal setHidden:NO];
            [cellMoney.textCouponLabel setHidden:NO];
        }
        
        if(_tax1Value.length > 0) {
            
            cellMoney.textTaxes.text = _tax1Value;
            cellMoney.textTaxesLabel.text = [_tax1Label uppercaseString];
            
        }
        
        cellMoney.textTaxesTotal.text = [NSString stringWithFormat:@"INR %.2f", totalAfterTaxes];
        
        return cellMoney;
        
    }
    
    
    // Configure the cell
    
    
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
    
    if(connection == _connDownloadCart) {
        
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
                _arrTitles = [[NSMutableArray alloc] init];
                _arrQuantities = [[NSMutableArray alloc] init];
                _arrPrices = [[NSMutableArray alloc] init];
                _arrDiscountedPrices = [[NSMutableArray alloc] init];
                _arrBookingPrices = [[NSMutableArray alloc] init];
                _arrPrices = [[NSMutableArray alloc] init];
                _arrPictures = [[NSMutableArray alloc] init];
                
                containsDiscount = false;
                
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
                        containsBooking = YES;
                    } else {
                        containsBooking = NO;
                    }
                    
                    if([priceMapped integerValue] == -1) {
                    } else {
                        priceItem = priceMapped;
                    }
                    
                    CGFloat priceF = [priceItem floatValue];
                    int quantityI = [quantity integerValue];
                    CGFloat costF = priceF * quantityI;
                    
                    NSString *discountedPrice = @"";
                    if([_nav getDiscount:discount] != nil) {
                        
                        containsDiscount = YES;
                        
                        NSDictionary *cv = [_nav getDiscount:discount];
                        NSString *type = [cv objectForKey:DB_COL_TITLE];
                        NSString *value = [cv objectForKey:DB_COL_PRICE];
                        CGFloat valueF = [value floatValue];
                        
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
                    
                    if(jsonArrPictures.count > 0) {
                        
                        NSDictionary *jsonObjPict = [jsonArrPictures objectAtIndex:0];
                        NSString *pathPicture = [jsonObjPict objectForKey:@"pathThumbnail"];
                        [_arrPictures addObject:pathPicture];
                        
                    }
                    
                }
                
                subTotal = 0;
                totalAfterCoupon = 0;
                
                // Calculate Price before Coupons
                
                for(int i = 0; i < _arrPrices.count; i++) {
                    
                    NSString *bookingPrice = [_arrBookingPrices objectAtIndex:i];
                    
                    if(bookingPrice.length > 0) {
                        
                        subTotal += [bookingPrice floatValue];
                        
                    } else {
                        
                        NSString *discountedPrice = [_arrDiscountedPrices objectAtIndex:i];
                        if(discountedPrice.length > 0) {
                            
                            subTotal += [discountedPrice floatValue];
                            
                        } else {
                            
                            NSString *price = [_arrPrices objectAtIndex:i];
                            subTotal += [price floatValue];
                            
                        }
                        
                    }
                    
                }
                
                CouponRecord *cr = [_nav getCouponAppliedToCart];
                if(cr == nil) {
                    totalAfterCoupon = subTotal;
                } else {
                    
                    NSString *type = cr.type;
                    NSString *value = cr.value;
                    CGFloat valueF = [value floatValue];
                    
                    CGFloat couponedPriceF = 0;
                    
                    if([type isEqualToString:DB_DISCOUNT_TYPE_PERCENTAGE]) {
                        
                        couponedPriceF = subTotal - ((subTotal*valueF)/100);
                        
                    } else {
                        
                        couponedPriceF = subTotal - valueF;
                        
                    }
                    
                    totalAfterCoupon = [[NSString stringWithFormat:@"%.2f", couponedPriceF] floatValue];
                    
                }
                
                TaxRecord *record = [_nav getTax1];
                if(record != Nil) {
                    _tax1Label = record.label;
                    _tax1Value = [NSString stringWithFormat:@"%@%%", record.value];
                    totalAfterTaxes = totalAfterCoupon + ((totalAfterCoupon*[_tax1Value floatValue])/100);
                } else {
                    _tax1Label = @"";
                    _tax1Value = @"";
                    totalAfterTaxes = totalAfterCoupon;
                }
                
                [self.collectionView reloadData];
                
            }
            
            
        }
        
    } else if(connection == _connValidateCoupon) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            NSString* value = [json objectForKey:@"value"];
            NSData *dataValue = [value dataUsingEncoding:NSUTF8StringEncoding];
            json = [NSJSONSerialization
                    JSONObjectWithData:dataValue //1
                    options:kNilOptions
                    error:&error];
            
            
            NSDictionary *jsonObj = (NSDictionary *)[NSJSONSerialization
                                                     JSONObjectWithData:dataValue //1
                                                     options:kNilOptions
                                                     error:&error];
            
            NSMutableArray *jsonArrTotal = [jsonObj objectForKey:@"total"];
            NSMutableArray *jsonArrAvailable = [jsonObj objectForKey:@"available"];
            
            
            Boolean couponIsValid = NO;
            if(jsonArrTotal.count > 0 && jsonArrAvailable.count > 0) {
                
                NSDictionary *jsonCoupon = [jsonArrAvailable objectAtIndex:0];
                
                CouponRecord *cr = [[CouponRecord alloc] init];
                cr.idCoupon = [jsonCoupon objectForKey:@"idCoupons"];
                cr.code = [jsonCoupon objectForKey:@"code"];
                cr.type = [jsonCoupon objectForKey:@"type"];
                cr.value = [jsonCoupon objectForKey:@"value"];
                cr.allowDoubleDiscouting = [jsonCoupon objectForKey:@"allowDoubleDiscounting"];
                cr.minPurchase = [jsonCoupon objectForKey:@"minPurchase"];
                cr.maxVal = [jsonCoupon objectForKey:@"maxVal"];
                
                if([cr.code isEqualToString:cellCoupon.fieldCoupon.text]) {
                    
                    NSDictionary *map = @{
                                          DB_COL_TYPE: DB_RECORD_TYPE_COUPON
                                          };
                    [[DbHelper getSharedInstance] deleteRecord:map];
                    
                    map = @{
                            DB_COL_TYPE: DB_RECORD_TYPE_COUPON,
                            DB_COL_NAME: cr.code,
                            DB_COL_TITLE: cr.type,
                            DB_COL_TIMESTAMP: [jsonCoupon objectForKey:@"timestamp"],
                            DB_COL_PRICE: cr.value,
                            DB_COL_CAPTION: cr.allowDoubleDiscouting,
                            DB_COL_SRV_ID: cr.idCoupon,
                            DB_COL_EXTRA_1: cr.maxVal,
                            DB_COL_EXTRA_2: cr.minPurchase
                            };
                    [[DbHelper getSharedInstance] insertRecord:map];
                    
                    if (cr.minPurchase != Nil && cr.minPurchase != (id)[NSNull null] && cr.minPurchase.length > 0) {
                        
                        NSArray *array = [cellMoney.textCouponTotal.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        
                        if([array[1] floatValue] < [cr.minPurchase floatValue]) {
                            
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                            message: [NSString stringWithFormat:@"Minimum purchase limit for this coupon is INR %@!", cr.minPurchase]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil, nil];
                            [alert show];
                            return;
                            
                        }
                        
                    }
                    
                    if(![cr.allowDoubleDiscouting isEqualToString:@"1"] && containsDiscount) {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                        message: @"Double discounting is not allowed for this coupon"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                        return;
                        
                    }
                    
                    NSDictionary *mapExisting = @{
                                                  DB_COL_TYPE: DB_RECORD_TYPE_CART
                                                  };
                    NSMutableArray *recordsCart = [[DbHelper getSharedInstance] retrieveRecords:map];
                    
                    if(recordsCart.count > 0) {
                        
                        map = @{
                                DB_COL_DISCOUNT: cr.idCoupon
                                };
                        [[DbHelper getSharedInstance] updateRecord:map whereRecord:mapExisting];
                        couponIsValid = true;
                        
                    }
                    
                }
                
            }
            
            if(!couponIsValid) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                message:@"Coupon is not valid!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                
            } else {
                
                [self loadFromDb];
                
            }
            
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self viewDidLoad];
    [self viewDidAppear:YES];
    
}

- (void)userTappedOnRemove:(UIGestureRecognizer*)gestureRecognizer {
    
    _alertConfirmRemove = [[UIAlertView alloc] initWithTitle:@"Confirm Remove"
                                                    message:@"Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:@"NO", nil];
    [_alertConfirmRemove show];
    
    
    UILabel *labelCart = (UILabel *)gestureRecognizer.view;
    int index = labelCart.tag;
    alertRemoveIndex = index;
    
    
}

- (void)userTappedOnApplyCoupon:(UIGestureRecognizer*)gestureRecognizer;
{
 
    CouponRecord *cr = [_nav getCouponAppliedToCart];
    if(cr == Nil) {
        
        if(containsBooking) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Coupon cannot be applied for items with booking amounts!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_COUPON_VALIDATE];
            NSString *jsonStr = [NSString stringWithFormat:@"[{\"idProject\": \"%@\", \"idCountry\": \"%@\", \"idState\": \"%@\", \"idCity\": \"%@\"}]", PID, MY_COUNTRYID, MY_STATEID, MY_CITYID];
            NSString *myRequestString = [NSString stringWithFormat:@"params=%@", jsonStr];
            NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
            [ request setHTTPMethod: @"POST" ];
            [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [ request setHTTPBody: myRequestData ];
            
            _connValidateCoupon = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            
        }
        
    } else {
        
        [_nav removeAppliedCouponToCart];
        [self loadFromDb];
        
    }
    
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(alertView == _alertConfirmRemove) {
        
        if(buttonIndex == 0) {
            
            NSDictionary *map = @{
                                  DB_COL_ID: [_arrIdCart objectAtIndex:alertRemoveIndex]
                                  };
            [[DbHelper getSharedInstance] deleteRecord:map];
            [self loadFromDb];
            alertRemoveIndex = -1;
            
        }
        
    }
    
}

- (IBAction) changeQuantity:(id)sender;
{
    
    UITextField *view = (UITextField *)sender;
    
    if(view.text.length == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Quantity cannot be blank!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        view.text = @"1";
        return;
        
    }
    
    if([view.text integerValue] > 10) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Quantity cannot exceed 10!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        int index = view.tag;
        NSString *value = view.text;
        
        if(value.length > 0) {
            
            NSDictionary *mapwhere = @{
                                       DB_COL_ID: _arrIdCart[index]
                                       };
            NSDictionary *mapUpdate = @{
                                        DB_COL_CART_ITEM_QUANTITY: value
                                        };
            [[DbHelper getSharedInstance] updateRecord:mapUpdate whereRecord:mapwhere];
            [self loadFromDb];
            
        }
        
    }
    
}

- (void) tappedOnNext:(UIGestureRecognizer*)gestureRecognizer; {
    
    CheckoutTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckoutContainer"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}


@end
