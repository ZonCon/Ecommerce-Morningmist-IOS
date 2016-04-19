//
//  AboutListCollectionViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 04/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "globals.h"
#import "DbHelper.h"
#import "NavigationViewController.h"
#import "SyncViewController.h"
#import "AboutDetailsViewController.h"
#import "AboutListCollectionViewController.h"
#import "AboutListCollectionViewCell.h"
#import "AboutListFooterCollectionReusableView.h"

@interface AboutListCollectionViewController ()

@end

@implementation AboutListCollectionViewController

static NSString * const reuseIdentifier = @"AboutList";

@synthesize arrSubTitles = _arrSubTitles;
@synthesize arrIds = _arrIds;
@synthesize arrTitles = _arrTitles;
@synthesize arrPictures = _arrPictures;
@synthesize footerLabel = _footerLabel;
@synthesize _idSrv = __idSrv;

int ABOUT_OFFSET = 0;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrIds = [[NSMutableArray alloc]init];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrIds = [[NSMutableArray alloc]init];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    __idSrv = @"";
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrIds = [[NSMutableArray alloc]init];
    
    [self loadFromLocalDB];
    [self.collectionView reloadData];
    
}

- (void)loadFromLocalDB {
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrIds = [[NSMutableArray alloc]init];
    
    NSDictionary *cv = @{
                         DB_COL_TYPE: DB_STREAM_TYPE_MESSAGE
                         };
    NSMutableArray *arr = [[DbHelper getSharedInstance] retrieveRecords:cv];
    
    NSString *_idStream = @"";
    for(int i = 0; i < arr.count; i++) {
        
        cv = [arr objectAtIndex:i];
        NSString *name = [cv objectForKey:DB_COL_NAME];
        NSLog(@"Name=%@", name);
        
        if([[name lowercaseString] rangeOfString:@"about"].location != NSNotFound) {
            
            _idStream = [cv objectForKey:DB_COL_ID];
            __idSrv = [cv objectForKey:DB_COL_SRV_ID];
            break;
            
        }
        
    }
    
    if(_idStream.length > 0) {
        
        ABOUT_OFFSET = 0;
        
        cv = @{
               DB_COL_TYPE: DB_RECORD_TYPE_ITEM,
               DB_COL_FOREIGN_KEY: _idStream
               };
        
        arr = [[DbHelper getSharedInstance] retrieveRecords:cv];
        
        for(int i = 0; i < arr.count; i++) {
            
            cv = [arr objectAtIndex:i];
            
            [_arrTitles addObject:[cv objectForKey:DB_COL_TITLE]];
            [_arrSubTitles addObject:[cv objectForKey:DB_COL_SUBTITLE]];
            [_arrIds addObject:[cv objectForKey:DB_COL_SRV_ID]];
            
            ABOUT_OFFSET++;
            
            NSString *picture = @"";
            
            cv = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_PICTURE,
                   DB_COL_FOREIGN_KEY: [cv objectForKey:DB_COL_ID]
                   };
            
            NSMutableArray *arrPictures_1 = [[DbHelper getSharedInstance] retrieveRecords:cv];
            if(arrPictures_1.count > 0) {
                
                NSDictionary *cvPictures = [arrPictures_1 objectAtIndex:0];
                picture = [cvPictures objectForKey:DB_COL_PATH_PROC];
                
                //NSLog(@"Picture found = %@", picture);
                
            }
            [_arrPictures addObject:picture];
            
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"AboutDetails"])
    {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        int rowNo = indexPath.row;
        
        // Get reference to the destination view controller
        AboutDetailsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.idSrvStream = __idSrv;
        vc.idSrvItem = [_arrIds objectAtIndex:rowNo];
        
    }
    
}

#pragma mark <UICollectionViewDataSource>

- (void)dealloc {
    
    self.collectionView = nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AboutListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(_arrTitles.count > 0 && _arrSubTitles.count > 0) {
        
        NSString *title = [_arrTitles objectAtIndex: [indexPath row]];
        NSString *subTitle = [_arrSubTitles objectAtIndex: [indexPath row]];
        NSString *picture = [_arrPictures objectAtIndex: [indexPath row]];
        
        cell.title.text = title;
        cell.title.font = [UIFont systemFontOfSize:FONT_SIZE_LIST_TITLES];
        cell.subtitle.text = subTitle;
        cell.subtitle.font = [UIFont systemFontOfSize:FONT_SIZE_LIST_DESCS];
        
        NSLog(@"Picture=%@", picture);
        
        if(picture.length > 0) {
            
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSArray *arrPath =[picture componentsSeparatedByString: @"/"];
            NSString *fileName = [arrPath objectAtIndex:(arrPath.count - 1)];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            //NSLog(@"Logging picture=%@", filePath);
            NSLog(@"Displaying exists picture=%d", fileExists);
            
            
            NSError *attributesError = nil;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&attributesError];
            
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            if(fileExists && fileSize > 1000) {
                
                NSData * data = [NSData dataWithContentsOfFile:filePath];
                if(data) {
                    UIImage *original=[UIImage imageWithData:data];
                    UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:0.1 orientation:original.imageOrientation];
                    cell.picture.image=small;
                }
            } else {
                
                NSString *pictureUrl = [NSString stringWithFormat:@"%@%@%@", SERVER, UPLOADS, picture];
                NSLog(@"Displaying Downloading picture=%@==", pictureUrl);
                NSURL *url = [NSURL URLWithString:pictureUrl];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                 {
                     
                     if(error == nil) {
                         
                         [data writeToFile:filePath atomically:YES];
                         UIImage *original=[UIImage imageWithData:data];
                         UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:0.1 orientation:original.imageOrientation];
                         cell.picture.image=small;
                         
                     }
                     
                 }];
                
            }
            
        } else {
            cell.picture.image = [UIImage imageNamed: @"cover.jpg"];
        }
        
        [cell.picture.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [cell.picture.layer setBorderWidth: 1.0];
        
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AboutListHeader" forIndexPath:indexPath];
        
        return headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        AboutListFooterCollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"AboutListFooter" forIndexPath:indexPath];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleLoadMore:)];
        [footerview.textLoadmore addGestureRecognizer:singleFingerTap];
        [footerview.textLoadmore setUserInteractionEnabled:YES];
        _footerLabel = footerview.textLoadmore;
        _footerLabel.font = [UIFont systemFontOfSize:FONT_SIZE_LIST_LOADMORE];
        
        return footerview;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat widthOfScreen  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = widthOfScreen;
    return CGSizeMake(width, 151);
}


- (void)handleLoadMore:(UITapGestureRecognizer *)recognizer {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_INDI_STREAMS];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"idCountry\": \"%@\", \"idState\": \"%@\", \"idCity\": \"%@\", \"offset\": \"%d\", \"idStream\": \"%@\"}]", PID, MY_COUNTRYID, MY_STATEID, MY_CITYID, ABOUT_OFFSET, __idSrv];
    
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    //NSURL *url = [NSURL URLWithString:pictureUrl];
    //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if(error == nil) {
             
             NSDictionary* json = [NSJSONSerialization
                                   JSONObjectWithData:data
                                   options:kNilOptions
                                   error:&error];
             
             NSString *result = [json objectForKey:@"result"];
             if([result isEqualToString:RESULT_SUCCES]) {
                 
                 NSString *value = [json objectForKey:@"value"];
                 NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                 NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                 
                 if(arr.count == 0) {
                     _footerLabel.text = @"REACHED THE END";
                 }
                 
                 for(int i = 0; i < arr.count; i++) {
                     
                     NSDictionary *objItem = [arr objectAtIndex:i];
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
                     
                     NSString *discount;
                     NSString *priceMapped = (NSString *)[objItem objectForKey:@"price"];
                     NSString *discountMapped = (NSString *)[objItem objectForKey:@"discount"];
                     
                     
                     if([priceMapped integerValue] == -1) {
                     } else {
                         price = priceMapped;
                     }
                     
                     if([discountMapped integerValue] == -1) {
                         if([jsonObjItemsItems objectForKey:@"Discounts_idDiscounts"] == (id)[NSNull null]) {
                             discount = @"";
                         } else {
                             discount = [jsonObjItemsItems objectForKey:@"Discounts_idDiscounts"];
                         }
                     } else {
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
                     
                     NSDictionary *cv = @{
                                          DB_COL_SRV_ID: __idSrv,
                                          DB_COL_TYPE: DB_STREAM_TYPE_MESSAGE
                                          };
                     NSString *_idStream = [[DbHelper getSharedInstance] retrieve_id:cv];
                     
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
                 
                 [self loadFromLocalDB];
                 [self.collectionView reloadData];
                 
             }
             
         }
         
     }];
    
    
}

@end
