//
//  SyncViewController.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 31/10/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import "SyncViewController.h"
//#import "TabBarViewController.h"
#import "NavigationViewController.h"
#import "SelectLocationController.h"
#import "globals.h"
#import "DbHelper.h"
#import "AppDelegate.h"

@interface SyncViewController ()

@end

@implementation SyncViewController

NSString *MY_COUNTRYID = @"";
NSString *MY_COUNTRYNAME = @"";
NSString *MY_STATEID = @"";
NSString *MY_STATENAME = @"";
NSString *MY_CITYID = @"";
NSString *MY_CITYNAME = @"";
NSString *MY_EMAIL = @"";
NSString *MY_NAME = @"";
NSString *MY_TOKEN = @"";
NSString *PUSH_TOKEN = @"";
NSMutableArray *ARR_RATES;
CGFloat SCREEN_HEIGHT;
CGFloat SCREEN_WIDTH;
BOOL IS_SIGNED_IN = false;
BOOL IS_OPENED_FROM_DETAIL = false;
BOOL IS_OPENED_FROM_MENU = false;
BOOL IS_OPENED_FROM_RESET = false;
BOOL IS_OPENED_FROM_FORGOT = false;
BOOL IS_OPENED_FROM_CART = false;

static NSMutableData *_responseData;
@synthesize connLogin = _connLogin;
@synthesize picture = _picture;
@synthesize activityView = _activityView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_activityView startAnimating];
    
    [self.view endEditing:YES];
    
}

- (void)doSync {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    @try {
        
        SCREEN_HEIGHT = [[UIScreen mainScreen] bounds].size.height;
        SCREEN_WIDTH = [[UIScreen mainScreen] bounds].size.width;
        
        if([self populateMyLocation]) {
            
            [self populateMyCredentials];
            [self downloadLogin];
            [self downloadStreams];
            
        } else {
            
            SelectLocationController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectLocation"];
            vc.fromStart = true;
            [self presentViewController:vc animated:NO completion:nil];
            
        }
        
        
    }@catch(NSException *theException) {
        
        NSLog(@"An exception occurred: %@", theException.name);
        NSLog(@"Here are some details: %@", theException.reason);
        
    }
    
    NavigationViewController *lbc = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationContainer"];
    if(appDelegate.notifParams != NULL) {
        lbc.notifParams = appDelegate.notifParams;
    }
    appDelegate.navController = lbc;
    [self presentViewController:lbc animated:NO completion:nil];
    
    IS_OPENED_FROM_DETAIL = false;
    IS_OPENED_FROM_FORGOT = false;
    IS_OPENED_FROM_MENU = false;
    IS_OPENED_FROM_RESET = false;
    IS_OPENED_FROM_CART = false;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self performSelector:@selector(doSync)
               withObject:(self)
               afterDelay:(1.0)];
    
    [self.view endEditing:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkIfDBPopulated {
    
    NSDictionary *cv = @{
                         DB_COL_TYPE: DB_STREAM_TYPE_PRODUCT
                         };
    
    NSMutableArray *arr = [[DbHelper getSharedInstance] retrieveRecords:cv];
    if(arr.count > 0) {
        return true;
    } else {
        return false;
    }
    
    
}

- (void)clearDynamicDB {
    
    [[DbHelper getSharedInstance] clearDynamicDataFromDB];
    
}

- (void)displayNotification: (NSString *)msg params:(NSString *)params {
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    // current time plus 10 secs
    NSDate *now = [NSDate date];
    NSDate *dateToFire = [now dateByAddingTimeInterval:5];
    
    //NSLog(@"now time: %@", now);
    //NSLog(@"fire time: %@", dateToFire);
    
    localNotification.fireDate = dateToFire;
    localNotification.alertBody = msg;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1; // increment
    
    NSDictionary *infoDict = @{
                               @"params": params
                               };
    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    //[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    
}

- (void)downloadStreams {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_STREAMS];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"idCountry\": \"%@\", \"idState\": \"%@\", \"idCity\": \"%@\"}]", PID, MY_COUNTRYID, MY_STATEID, MY_CITYID];
    
    NSLog(@"URL=%@", urlString);
    NSLog(@"REQUEST=%@", myRequestString);
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request;
    if([self checkIfDBPopulated]) {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:3.0];
    } else {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    }
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    NSURLResponse* response;
    NSError* error = nil;
    NSData *dataR = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:dataR
                          options:kNilOptions
                          error:&error];
    
    NSString *result = [json objectForKey:@"result"];
    NSLog(@"Result=%@", result);
    if([result isEqualToString:RESULT_SUCCES]) {
        
        [self clearDynamicDB];
        
        NSString *value = [json objectForKey:@"value"];
        NSLog(@"Value=%@", value);
        NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        //NSLog(@"Items=%d", arr.count);
        for(int i = 0; i < arr.count; i++) {
            
            NSDictionary *cv = (NSDictionary *)[arr objectAtIndex:i];
            
            if([cv objectForKey:@"productstream"] != nil) {
                
                NSDictionary *objStream;
                
                if([cv objectForKey:@"productstream"] != nil) {
                    objStream = [cv objectForKey:@"productstream"];
                }
                
                NSArray *objItems;
                objItems = [cv objectForKey:@"productitems"];
                
                NSString *idSrvStream = (NSString *)[objStream objectForKey:@"idProductstreamContainer"];
                NSString *name = (NSString *)[objStream objectForKey:@"name"];
                NSString *type = (NSString *)[objStream objectForKey:@"type"];
                NSLog(@"Stream = %@, %@", name, type);
                NSString *_idStream;
                NSDictionary *cv = @{
                                     DB_COL_NAME: name,
                                     DB_COL_TYPE: type,
                                     DB_COL_SRV_ID: idSrvStream
                                     };
                [[DbHelper getSharedInstance] insertRecord:cv];
                _idStream = [[DbHelper getSharedInstance] retrieve_id:cv];
                
                NSLog(@"Stream items = %d", objItems.count);
                
                for(int j = 0; j < objItems.count; j++) {
                    
                    NSDictionary *objItem = [objItems objectAtIndex:j];
                    NSDictionary *jsonObjItemsItems = [objItem objectForKey:@"items"];
                    NSArray *jsonArrItemsPictures = [objItem objectForKey:@"pictures"];
                    NSArray *jsonArrItemsUrls = [objItem objectForKey:@"urls"];
                    NSArray *jsonArrItemsLocations = [objItem objectForKey:@"locations"];
                    NSArray *jsonArrItemsContacts = [objItem objectForKey:@"contacts"];
                    NSArray *jsonArrItemsAttachments = [objItem objectForKey:@"attachments"];
                    
                    NSString *idSrvProductitems = [jsonObjItemsItems objectForKey:@"idProductitems"];
                    NSString *title = [[jsonObjItemsItems objectForKey:@"title"] stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                    NSString *subtitle = [[jsonObjItemsItems objectForKey:@"subtitle"] stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                    NSString *content = [[jsonObjItemsItems objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                    NSString *timestamp = [jsonObjItemsItems objectForKey:@"timestampPublish"];
                    NSString *stock = [jsonObjItemsItems objectForKey:@"stockCurrent"];
                    NSString *size = [jsonObjItemsItems objectForKey:@"size"];
                    NSString *weight = [jsonObjItemsItems objectForKey:@"weight"];
                    NSString *sku = [jsonObjItemsItems objectForKey:@"sku"];
                    NSString *price = [jsonObjItemsItems objectForKey:@"price"];
                    NSString *extra1 = [jsonObjItemsItems objectForKey:@"extra1"];
                    NSString *extra2 = [jsonObjItemsItems objectForKey:@"extra2"];
                    NSString *extra3 = [jsonObjItemsItems objectForKey:@"extra3"];
                    NSString *extra4 = [jsonObjItemsItems objectForKey:@"extra4"];
                    NSString *extra5 = [jsonObjItemsItems objectForKey:@"extra5"];
                    NSString *extra6 = [jsonObjItemsItems objectForKey:@"extra6"];
                    NSString *extra7 = [jsonObjItemsItems objectForKey:@"extra7"];
                    NSString *extra8 = [jsonObjItemsItems objectForKey:@"extra8"];
                    NSString *extra9 = [jsonObjItemsItems objectForKey:@"extra9"];
                    NSString *extra10 = [jsonObjItemsItems objectForKey:@"extra10"];
                    NSString *booking = [jsonObjItemsItems objectForKey:@"bookingPrice"];
                    
                    NSLog(@"Title=%@", title);
                    NSLog(@"Srvid=%@", idSrvProductitems);
                    NSLog(@"Type=%@", type);
                    
                    NSString *discount;
                    NSString *priceMapped = (NSString *)[objItem objectForKey:@"price"];
                    NSString *discountMapped = (NSString *)[objItem objectForKey:@"discount"];
                    
                    NSLog(@"Discount mapped=%@", discountMapped);
                    NSLog(@"Price mapped=%@", priceMapped);
                    
                    
                    if([priceMapped integerValue] == -1) {
                        NSLog(@"Pricemapped contains");
                    } else {
                        NSLog(@"Pricemapped does not contain");
                        price = priceMapped;
                    }
                    
                    if([discountMapped integerValue] == -1) {
                        NSLog(@"Discountmapped contains");
                        if([jsonObjItemsItems objectForKey:@"Discounts_idDiscounts"] == (id)[NSNull null]) {
                            discount = @"";
                        } else {
                            discount = [jsonObjItemsItems objectForKey:@"Discounts_idDiscounts"];
                        }
                    } else {
                        NSLog(@"Discountmapped does not contain");
                        discount = discountMapped;
                    }
                    
                    if(title ==(id)[NSNull null]) {
                        title = @"";
                    }
                    
                    if(subtitle ==(id)[NSNull null]) {
                        subtitle = @"";
                    }
                    
                    if(content ==(id)[NSNull null]) {
                        content = @"";
                    }
                    
                    if(timestamp ==(id)[NSNull null]) {
                        timestamp = @"";
                    }
                    
                    if(stock ==(id)[NSNull null]) {
                        stock = @"";
                    }
                    
                    
                    if(weight ==(id)[NSNull null]) {
                        weight = @"";
                    }
                    
                    if(sku ==(id)[NSNull null]) {
                        sku = @"";
                    }
                    
                    if(price ==(id)[NSNull null]) {
                        price = @"";
                    }
                    
                    if(booking ==(id)[NSNull null]) {
                        booking = @"";
                    }
                    
                    if(extra1 ==(id)[NSNull null]) {
                        extra1 = @"";
                    }
                    
                    if(extra2 ==(id)[NSNull null]) {
                        extra2 = @"";
                    }
                    
                    if(extra3 ==(id)[NSNull null]) {
                        extra3 = @"";
                    }
                    
                    if(extra4 ==(id)[NSNull null]) {
                        extra4 = @"";
                    }
                    
                    if(extra5 ==(id)[NSNull null]) {
                        extra5 = @"";
                    }
                    
                    if(extra6 ==(id)[NSNull null]) {
                        extra6 = @"";
                    }
                    
                    if(extra7 ==(id)[NSNull null]) {
                        extra7 = @"";
                    }
                    
                    if(extra8 ==(id)[NSNull null]) {
                        extra8 = @"";
                    }
                    
                    if(extra9 ==(id)[NSNull null]) {
                        extra9 = @"";
                    }
                    
                    if(extra10 ==(id)[NSNull null]) {
                        extra10 = @"";
                    }
                    
                    NSLog(@"Discount=%@", discount);
                    NSLog(@"price=%@", price);
                    NSLog(@"Extra1=%@", extra1);
                    
                    cv = @{
                           DB_COL_SRV_ID: idSrvProductitems,
                           DB_COL_TITLE: title,
                           DB_COL_TYPE: DB_RECORD_TYPE_ITEM,
                           DB_COL_SUBTITLE: subtitle,
                           DB_COL_CONTENT: content,
                           DB_COL_TIMESTAMP: timestamp,
                           DB_COL_STOCK: stock,
                           DB_COL_SIZE: size,
                           DB_COL_WEIGHT: weight,
                           DB_COL_SKU: sku,
                           DB_COL_PRICE: price,
                           DB_COL_FOREIGN_KEY: _idStream,
                           DB_COL_EXTRA_1: extra1,
                           DB_COL_EXTRA_2: extra2,
                           DB_COL_EXTRA_3: extra3,
                           DB_COL_EXTRA_4: extra4,
                           DB_COL_EXTRA_5: extra5,
                           DB_COL_EXTRA_6: extra6,
                           DB_COL_EXTRA_7: extra7,
                           DB_COL_EXTRA_8: extra8,
                           DB_COL_EXTRA_9: extra9,
                           DB_COL_EXTRA_10: extra10,
                           DB_COL_BOOKING: booking,
                           DB_COL_DISCOUNT: discount
                           };
                    [[DbHelper getSharedInstance] insertRecord:cv];
                    
                    NSString *_idItem;
                    cv = @{
                           DB_COL_SRV_ID: idSrvProductitems,
                           DB_COL_FOREIGN_KEY: _idStream,
                           DB_COL_TYPE: DB_RECORD_TYPE_ITEM
                           };
                    _idItem = [[DbHelper getSharedInstance] retrieve_id:cv];
                    
                    if(jsonArrItemsPictures.count > 0) {
                        
                        for(int l = 0; l < jsonArrItemsPictures.count; l++) {
                            
                            NSDictionary *jsonObjPictures = (NSDictionary *)[jsonArrItemsPictures objectAtIndex:l];
                            NSString *pathOrig = (NSString *)[jsonObjPictures objectForKey:@"pathOriginal"];
                            NSString *pathProc = (NSString *)[jsonObjPictures objectForKey:@"pathProcessed"];
                            NSString *pathTh = (NSString *)[jsonObjPictures objectForKey:@"pathThumbnail"];
                            
                            NSArray *strArrOrig = [pathOrig componentsSeparatedByString: @"/"];
                            NSArray *strArrProc = [pathProc componentsSeparatedByString: @"/"];
                            NSArray *strArrTh = [pathTh componentsSeparatedByString: @"/"];
                            
                            cv = @{
                                   DB_COL_TYPE: DB_RECORD_TYPE_PICTURE,
                                   DB_COL_PATH_ORIG: [strArrOrig objectAtIndex:(strArrOrig.count - 1)],
                                   DB_COL_PATH_PROC: [strArrProc objectAtIndex:(strArrProc.count - 1)],
                                   DB_COL_PATH_TH: [strArrTh objectAtIndex:(strArrTh.count - 1)],
                                   DB_COL_FOREIGN_KEY: _idItem
                                   };
                            
                            [[DbHelper getSharedInstance] insertRecord:cv];
                            
                        }
                        
                    }
                    
                    if(jsonArrItemsAttachments.count > 0) {
                        
                        for(int l = 0; l < jsonArrItemsAttachments.count; l++) {
                            
                            NSDictionary *jsonObjAttachments = (NSDictionary *)[jsonArrItemsAttachments objectAtIndex:l];
                            NSString *caption = (NSString *)[[jsonObjAttachments objectForKey:@"caption"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            NSString *value = (NSString *)[jsonObjAttachments objectForKey:@"path"];
                            
                            cv = @{
                                   DB_COL_TYPE: DB_RECORD_TYPE_ATTACHMENT,
                                   DB_COL_CAPTION: caption,
                                   DB_COL_URL: value,
                                   DB_COL_FOREIGN_KEY: _idItem
                                   };
                            
                            [[DbHelper getSharedInstance] insertRecord:cv];
                            
                        }
                        
                    }
                    
                    if(jsonArrItemsContacts.count > 0) {
                        
                        for(int l = 0; l < jsonArrItemsContacts.count; l++) {
                            
                            NSDictionary *jsonObjContacts = (NSDictionary *)[jsonArrItemsContacts objectAtIndex:l];
                            NSString *name = (NSString *)[[jsonObjContacts objectForKey:@"name"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            NSString *email = (NSString *)[[jsonObjContacts objectForKey:@"email"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            NSString *phone = (NSString *)[[jsonObjContacts objectForKey:@"phone"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            
                            cv = @{
                                   DB_COL_TYPE: DB_RECORD_TYPE_CONTACT,
                                   DB_COL_NAME: name,
                                   DB_COL_EMAIL: email,
                                   DB_COL_PHONE: phone,
                                   DB_COL_FOREIGN_KEY: _idItem
                                   };
                            
                            [[DbHelper getSharedInstance] insertRecord:cv];
                        }
                        
                    }
                    
                    if(jsonArrItemsLocations.count > 0) {
                        
                        for(int l = 0; l < jsonArrItemsLocations.count; l++) {
                            
                            NSDictionary *jsonObjLocations = (NSDictionary *)[jsonArrItemsLocations objectAtIndex:l];
                            NSString *caption = (NSString *)[[jsonObjLocations objectForKey:@"caption"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            NSString *location = (NSString *)[[jsonObjLocations objectForKey:@"location"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            
                            cv = @{
                                   DB_COL_TYPE: DB_RECORD_TYPE_LOCATION,
                                   DB_COL_FOREIGN_KEY: _idItem,
                                   DB_COL_CAPTION: caption,
                                   DB_COL_LOCATION: location
                                   };
                            
                            [[DbHelper getSharedInstance] insertRecord:cv];
                            
                        }
                        
                    }
                    
                    if(jsonArrItemsUrls.count > 0) {
                        
                        for(int l = 0; l < jsonArrItemsUrls.count; l++) {
                            
                            NSDictionary *jsonObjUrls = (NSDictionary *)[jsonArrItemsUrls objectAtIndex:l];
                            NSString *caption = (NSString *)[[jsonObjUrls objectForKey:@"caption"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            NSString *value = (NSString *)[[jsonObjUrls objectForKey:@"value"]stringByReplacingOccurrencesOfString:@"'" withString:@"'"];
                            
                            cv = @{
                                   DB_COL_TYPE: DB_RECORD_TYPE_URL,
                                   DB_COL_FOREIGN_KEY: _idItem,
                                   DB_COL_CAPTION: caption,
                                   DB_COL_URL: value
                                   };
                            
                            [[DbHelper getSharedInstance] insertRecord:cv];
                            
                        }
                        
                    }
                    
                }
                
            } else if([cv objectForKey:@"discounts"] != nil) {
                
                NSArray *objItems;
                objItems = [cv objectForKey:@"discounts"];
                
                NSLog(@"Discount items = %lu", (unsigned long)objItems.count);
                
                for(int j = 0; j < objItems.count; j++) {
                    
                    NSDictionary *jsonObj = [objItems objectAtIndex:j];
                    
                    NSString *idSrv = [jsonObj objectForKey:@"idDiscounts"];
                    NSString *code = [jsonObj objectForKey:@"code"];
                    NSString *type = [jsonObj objectForKey:@"type"];
                    NSString *value = [jsonObj objectForKey:@"value"];
                    NSString *timestamp = [jsonObj objectForKey:@"timestamp"];
                    
                    NSDictionary *cvDiscount = @{
                                                 DB_COL_TYPE: DB_RECORD_TYPE_DISCOUNT,
                                                 DB_COL_NAME: code,
                                                 DB_COL_TITLE: type,
                                                 DB_COL_TIMESTAMP: timestamp,
                                                 DB_COL_PRICE: value,
                                                 DB_COL_SRV_ID: idSrv
                                                 };
                    [[DbHelper getSharedInstance] insertRecord:cvDiscount];
                    
                }
                
            } else if([cv objectForKey:@"coupons"] != nil) {
                
                NSArray *objItems;
                objItems = [cv objectForKey:@"coupons"];
                
                NSLog(@"Coupon items = %lu", (unsigned long)objItems.count);
                
                for(int j = 0; j < objItems.count; j++) {
                    
                    NSDictionary *jsonObj = [objItems objectAtIndex:j];
                    
                    NSString *idSrv = [jsonObj objectForKey:@"idCoupons"];
                    NSString *code = [jsonObj objectForKey:@"code"];
                    NSString *type = [jsonObj objectForKey:@"type"];
                    NSString *value = [jsonObj objectForKey:@"value"];
                    NSString *timestamp = [jsonObj objectForKey:@"timestamp"];
                    NSString *allowDouble = [jsonObj objectForKey:@"allowDoubleDiscounting"];
                    NSString *maxVal = [jsonObj objectForKey:@"maxVal"];
                    NSString *minPurchase = [jsonObj objectForKey:@"minPurchase"];
                    
                    NSDictionary *cvDiscount = @{
                                                 DB_COL_TYPE: DB_RECORD_TYPE_COUPON,
                                                 DB_COL_NAME: code,
                                                 DB_COL_TITLE: type,
                                                 DB_COL_TIMESTAMP: timestamp,
                                                 DB_COL_PRICE: value,
                                                 DB_COL_SRV_ID: idSrv,
                                                 DB_COL_CAPTION: allowDouble,
                                                 DB_COL_EXTRA_1: maxVal,
                                                 DB_COL_EXTRA_2: minPurchase
                                                 };
                    [[DbHelper getSharedInstance] insertRecord:cvDiscount];
                    
                }
                
            } else if([cv objectForKey:@"taxes"] != nil) {
                
                NSDictionary *objTaxes;
                objTaxes = [cv objectForKey:@"taxes"];
                
                NSString *taxLabel1 = [objTaxes objectForKey:@"taxLabel1"];
                NSString *taxLabel2 = [objTaxes objectForKey:@"taxLabel2"];
                //NSString *taxLabel3 = [objTaxes objectForKey:@"taxLabel3"];
                NSString *taxValue1 = [objTaxes objectForKey:@"taxValue1"];
                NSString *taxValue2 = [objTaxes objectForKey:@"taxValue2"];
                //NSString *taxValue3 = [objTaxes objectForKey:@"taxValue3"];
                
                if(taxValue1.length > 0 && taxLabel1.length > 0) {
                    
                    NSDictionary *cvTax = @{
                                            DB_COL_TYPE: DB_RECORD_TYPE_TAX_1,
                                            DB_COL_TITLE: taxLabel1,
                                            DB_COL_SUBTITLE: taxValue1,
                                            };
                    [[DbHelper getSharedInstance] insertRecord:cvTax];
                    
                    
                }
                
                if(taxValue1.length > 0 && taxLabel1.length > 0) {
                    
                    if(![taxValue2 isEqualToString:@"null"] && ![taxLabel2 isEqualToString:@"null"]) {
                        
                        NSDictionary *cvTax = @{
                                                DB_COL_TYPE: DB_RECORD_TYPE_TAX_1,
                                                DB_COL_TITLE: taxLabel1,
                                                DB_COL_SUBTITLE: taxValue1,
                                                };
                        [[DbHelper getSharedInstance] insertRecord:cvTax];
                        
                    }
                    
                    
                }

            }
            
            [[DbHelper getSharedInstance] printDB];
            
        }
        
        
    }
    
    
}

- (Boolean)populateMyLocation {
    
    NSDictionary *cvCountry = @{
                                DB_COL_TYPE: DB_RECORD_TYPE_MY_COUNTRY
                                };
    
    NSDictionary *cvState = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_STATE
                              };
    
    NSDictionary *cvCity = @{
                             DB_COL_TYPE: DB_RECORD_TYPE_MY_CITY
                             };
    
    NSMutableArray *arrCountry = [[DbHelper getSharedInstance] retrieveRecords:cvCountry];
    NSMutableArray *arrState = [[DbHelper getSharedInstance] retrieveRecords:cvState];
    NSMutableArray *arrCity = [[DbHelper getSharedInstance] retrieveRecords:cvCity];
    
    if(arrCountry.count > 0 && arrState.count > 0 && arrCity.count > 0) {
        
        cvCountry = [arrCountry objectAtIndex:0];
        MY_COUNTRYID = (NSString *)[cvCountry objectForKey:DB_COL_SRV_ID];
        MY_COUNTRYNAME = (NSString *)[cvCountry objectForKey:DB_COL_NAME];
        
        cvState = [arrState objectAtIndex:0];
        MY_STATEID = (NSString *)[cvState objectForKey:DB_COL_SRV_ID];
        MY_STATENAME = (NSString *)[cvState objectForKey:DB_COL_NAME];
        
        cvCity = [arrCity objectAtIndex:0];
        MY_CITYID = (NSString *)[cvCity objectForKey:DB_COL_SRV_ID];
        MY_CITYNAME = (NSString *)[cvCity objectForKey:DB_COL_NAME];
        
        return true;
        
    } else {
        
        MY_COUNTRYID = @"";
        MY_COUNTRYNAME = @"";
        MY_STATEID = @"";
        MY_STATENAME = @"";
        MY_CITYID = @"";
        MY_CITYNAME = @"";
        
        return false;
        
    }
    
}

- (void)populateMyCredentials {
    
    NSDictionary *cvEmail = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_EMAIL
                              };
    //NSDictionary *cvName = @{
    //                       DB_COL_TYPE: DB_RECORD_TYPE_MY_NAME
    //                     };
    NSDictionary *cvToken = @{
                              DB_COL_TYPE: DB_RECORD_TYPE_MY_TOKEN
                              };
    
    
    NSMutableArray *arrEmail = [[DbHelper getSharedInstance] retrieveRecords:cvEmail];
    // NSMutableArray *arrName = [[DbHelper getSharedInstance] retrieveRecords:cvName];
    NSMutableArray *arrToken = [[DbHelper getSharedInstance] retrieveRecords:cvToken];
    
    //NSLog(@"Populating credentials %d, %d", arrEmail.count, arrToken.count);
    
    if(arrEmail.count > 0 && arrToken.count > 0) {
        
        cvEmail = [arrEmail objectAtIndex:0];
        MY_EMAIL = (NSString *)[cvEmail objectForKey:DB_COL_EMAIL];
        
        cvToken = [arrToken objectAtIndex:0];
        MY_TOKEN = (NSString *)[cvToken objectForKey:DB_COL_TITLE];
        
        //cvName = [arrName objectAtIndex:0];
        //MY_NAME = (NSString *)[cvName objectForKey:DB_COL_TITLE];
        
    } else {
        
        MY_EMAIL = @"";
        MY_TOKEN = @"";
        MY_NAME = @"";
        
    }
    
}

-(void) downloadLogin {
    
    @try {
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_VERIFY_LOGIN];
        NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"token\": \"%@\"}]", PID, MY_EMAIL, MY_TOKEN];
        
        //NSLog(urlString);
        //NSLog(myRequestString);
        NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
        NSMutableURLRequest *request;
        if([self checkIfDBPopulated]) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:3.0];
        } else {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
        }
        [ request setHTTPMethod: @"POST" ];
        [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [ request setHTTPBody: myRequestData ];
        
        //    _connLogin = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSURLResponse* response;
        NSError* error = nil;
        NSData *dataR = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        //NSString *data = [[NSString alloc] initWithData:dataR encoding:NSASCIIStringEncoding];
        //NSLog(@"%@", data);
        
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:dataR
                              options:kNilOptions
                              error:&error];
        
        NSString *result = [json objectForKey:@"result"];
        if([result isEqualToString:RESULT_SUCCES]) {
            
            IS_SIGNED_IN = true;
            
        }
        
    }@catch(NSException *e) {
        
        if(MY_TOKEN.length > 0 && MY_EMAIL.length > 0) {
            
            IS_SIGNED_IN = true;
            
        }
        
    }
    
    
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
    
    if(connection == _connLogin) {
        
        //NSString *data = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
        //NSLog(@"%@", data);
        
        //NSError* error;
        //NSDictionary* json = [NSJSONSerialization
          //                    JSONObjectWithData:_responseData //1
                              
            //                  options:kNilOptions
              //                error:&error];
        
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

@end
