//
//  OrdersListCollectionViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 21/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "globals.h"
#import "DbHelper.h"
#import "NavigationViewController.h"
#import "SyncViewController.h"
#import "OrdersListCollectionViewCell.h"
#import "OrdersListFooterCollectionReusableView.h"
#import "OrdersListCollectionViewController.h"
#import "OrderDetailsViewController.h"

@interface OrdersListCollectionViewController ()

@end

@implementation OrdersListCollectionViewController

static NSMutableData *_responseData;
@synthesize connList = _connList;
@synthesize arrDesc = _arrDesc;
@synthesize arrTime = _arrTime;
@synthesize arrPrice = _arrPrice;
@synthesize arrOrders = _arrOrders;
@synthesize footerLabel = _footerLabel;
@synthesize _idSrv = __idSrv;

static NSString * const reuseIdentifier = @"OrdersListCell";

int ORDERS_LIST_OFFSET = 0;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    ORDERS_LIST_OFFSET = 0;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    ORDERS_LIST_OFFSET = 0;
    
    NavigationViewController *tab = (NavigationViewController *)self.navigationController;
    
    self.navigationItem.title = @"Orders List";
    
    _arrTime = [[NSMutableArray alloc] init];
    _arrPrice = [[NSMutableArray alloc] init];
    _arrDesc = [[NSMutableArray alloc] init];
    _arrOrders = [[NSMutableArray alloc] init];
    __idSrv = @"";
    
    if([tab isNetworkAvailable]) {
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

- (void)initiateDownload {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_ORDERS_LIST];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"token\": \"%@\", \"offset\": \"%d\"}]", PID, MY_EMAIL, MY_TOKEN, ORDERS_LIST_OFFSET];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    
    _connList = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)loadFromArrays {
    
    _arrTime = [[NSMutableArray alloc] init];
    _arrPrice = [[NSMutableArray alloc] init];
    _arrDesc = [[NSMutableArray alloc] init];
    _arrOrders = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"OrderDetails"])
    {
    
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        int rowNo = indexPath.row;
        
        // Get reference to the destination view controller
        OrderDetailsViewController *vc = [segue destinationViewController];
        vc.idOrder = [_arrOrders objectAtIndex:rowNo];
        
    }
    
}

#pragma mark <UICollectionViewDataSource>

- (void)dealloc {
    
    self.collectionView = nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if(_arrPrice.count > 0) {
        return 1;
    } else {
        return 0;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_arrPrice.count == 0) {
        return 0;
    } else {
        return _arrPrice.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OrdersListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(_arrPrice.count > 0) {
        
        NSString *price = [_arrPrice objectAtIndex:[indexPath row]];
        NSString *time = [_arrTime objectAtIndex:[indexPath row]];
        NSString *desc = [_arrDesc objectAtIndex:[indexPath row]];
        NSString *idOrders = [_arrOrders objectAtIndex:[indexPath row]];
        cell.textPrice.text = [NSString stringWithFormat:@"INR %@", price];
        cell.textDate.text = [NSString stringWithFormat:@"%@", time];
        cell.textDesc.text = desc;
        cell.textOrder.text = idOrders;
        
    }
    
    // Configure the cell
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"OrdersListHeader" forIndexPath:indexPath];
        
        return headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter) {
        OrdersListFooterCollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"OrdersListFooter" forIndexPath:indexPath];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleLoadMore:)];
        [footerview.textFooter addGestureRecognizer:singleFingerTap];
        [footerview.textFooter setUserInteractionEnabled:YES];
        _footerLabel = footerview.textFooter;
        
        return footerview;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //CGFloat heightOfScreen = [[UIScreen mainScreen] bounds].size.height;
    CGFloat widthOfScreen  = [[UIScreen mainScreen] bounds].size.width;
    
    CGFloat width = widthOfScreen;
    
    return CGSizeMake(width, 107);
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
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              options:kNilOptions
                              error:&error];
        NSString* result = [json objectForKey:@"result"];
        
        if([result isEqualToString:@"success"]) {
            
            NSString* value = [json objectForKey:@"value"];
            NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArr = [NSJSONSerialization
                                JSONObjectWithData:jsonData //1
                                options:kNilOptions
                                error:&error];
            
            if(jsonArr.count > 0) {
                
                
                for(int i = 0; i < jsonArr.count; i++) {
                    
                    ORDERS_LIST_OFFSET++;
                    
                    NSDictionary *json = [jsonArr objectAtIndex:i];
                    NSString *taxedPrice = [json objectForKey:@"taxedPrice"];
                    NSString *timestamp = [json objectForKey:@"timestamp"];
                    NSString *order = [json objectForKey:@"idOrders"];
                    NSMutableArray *arr = [json objectForKey:@"items"];
                    
                    NSString *itemsStr = @"";
                    for(int j = 0; j < arr.count; j++) {
                        
                        NSDictionary *jsonItem = [arr objectAtIndex:j];
                        NSString *title = [jsonItem objectForKey:@"name"];
                        if(j == 0) {
                            itemsStr = [NSString stringWithFormat:@"%@", title];
                        } else {
                            itemsStr = [NSString stringWithFormat:@"%@, %@", itemsStr, title];
                        }
                        
                        
                    }
                    
                    [_arrTime addObject:timestamp];
                    [_arrPrice addObject:taxedPrice];
                    [_arrDesc addObject:itemsStr];
                    [_arrOrders addObject:[NSString stringWithFormat:@"#%@", order]];
                    
                }
                
                [self.collectionView reloadData];
                
            } else {
                
                _footerLabel.text = @"REACHED THE END";
                
            }
            
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self initiateDownload];
}

- (void)handleLoadMore:(UITapGestureRecognizer *)recognizer {
    
    [self initiateDownload];
    
}

@end
