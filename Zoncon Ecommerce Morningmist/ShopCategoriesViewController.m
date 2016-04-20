//
//  AbsWorldCollectionViewController.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 02/11/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import "ShopCategoriesViewController.h"
#import "ShopCategoriesViewCell.h"
#import "ShopItemsListCollectionViewController.h"
#import "globals.h"
#import "DbHelper.h"
#import "SyncViewController.h"
#import "AppDelegate.h"
#import "NavigationViewController.h"

@interface ShopCategoriesViewController ()

@end

@implementation ShopCategoriesViewController

@synthesize userDataPopover = _userDataPopover;
@synthesize arrNotifs = _arrNotifs;
@synthesize arrSrvIds = _arrSrvIds;
@synthesize arrTitles = _arrTitles;
@synthesize arrPictures = _arrPictures;

static NSString * const reuseIdentifier = @"Categories";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSrvIds = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrNotifs = [[NSMutableArray alloc]init];
    
    [self loadFromLocalDB];
    [self.collectionView reloadData];
    
    [self.view endEditing:YES];
    
    //To process push notifications access the notifparams variable from app delegate.
    //Check if it is not null and process further
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self.view endEditing:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSrvIds = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrNotifs = [[NSMutableArray alloc]init];
    
    NavigationViewController *navBarController = (NavigationViewController *)self.navigationController;
    [navBarController hideCartCount];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSrvIds = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrNotifs = [[NSMutableArray alloc]init];
    
    NavigationViewController *navBarController = (NavigationViewController *)self.navigationController;
    [navBarController showCartCount];
    
    [self loadFromLocalDB];
    [self.collectionView reloadData];
    
}

- (void)loadFromLocalDB {
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSrvIds = [[NSMutableArray alloc]init];
    _arrPictures = [[NSMutableArray alloc]init];
    _arrNotifs = [[NSMutableArray alloc]init];
    
    // Find streams
    NSDictionary *cv = @{
                         DB_COL_TYPE: DB_STREAM_TYPE_PRODUCT
                         };
    NSMutableArray *arr = [[DbHelper getSharedInstance] retrieveRecords:cv];
    
    for(int i = 0; i < arr.count; i++) {
        
        NSDictionary *cvStreams = arr[i];
        NSString *title = [cvStreams objectForKey:DB_COL_NAME];
        NSString *srvId = [cvStreams objectForKey:DB_COL_SRV_ID];
        NSString *_idStream = [cvStreams objectForKey:DB_COL_ID];
        NSString *picture = @"";
        
        //Find items belonging to the stream
        cv = @{
               DB_COL_TYPE: DB_RECORD_TYPE_ITEM,
               DB_COL_FOREIGN_KEY: _idStream
               };
        NSMutableArray *arrItems = [[DbHelper getSharedInstance] retrieveRecords:cv];
        if(arrItems.count > 0) {
            
            NSDictionary *cvItems = [arrItems objectAtIndex:0];
            NSString *_idItem = [cvItems objectForKey:DB_COL_ID];
            
            //Find pictures belonging to the item of the stream
            cv = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_PICTURE,
                   DB_COL_FOREIGN_KEY: _idItem
                   };
            
            NSMutableArray *arrPictures = [[DbHelper getSharedInstance] retrieveRecords:cv];
            if(arrPictures.count > 0) {
                
                
                NSDictionary *cvPictures = [arrPictures objectAtIndex:0];
                picture = [cvPictures objectForKey:DB_COL_PATH_PROC];
                
            }
            
        }
        
        cv = @{
               DB_COL_TYPE: DB_RECORD_TYPE_MESSAGESTREAM_NOTIFICATION_ALERT,
               DB_COL_SRV_ID: srvId
               };
        NSMutableArray *arrNotifs = [[DbHelper getSharedInstance] retrieveRecords:cv];
        if(arrNotifs.count > 0) {
            
            title = [title stringByAppendingString:@" (1)"];
            
        }
        
        if(![title isEqualToString:@"Terms"] && ![title isEqualToString:@"Terms (1)"] && ![title isEqualToString:@"TERMS"] && ![title isEqualToString:@"TERMS (1)"]) {
            
            [_arrTitles addObject:title];
            [_arrSrvIds addObject:srvId];
            [_arrPictures addObject:picture];
            
        }
        
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation



// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([[segue identifier] isEqualToString:@"ShopItemsList"])
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        int rowNo = indexPath.row;
        ShopItemsListCollectionViewController *vc = [segue destinationViewController];
        // Pass any objects to the view controller here, like...
        vc.idSrv = [_arrSrvIds objectAtIndex:rowNo];
        
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


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([indexPath row] != 0) {
        
        CGFloat widthOfScreen  = [[UIScreen mainScreen] bounds].size.width/2 - 15;
        CGFloat width = widthOfScreen;
        return CGSizeMake(width, width);
        
    } else {
        
        CGFloat widthOfScreen  = [[UIScreen mainScreen] bounds].size.width - 20;
        CGFloat width = widthOfScreen;
        CGFloat height = (widthOfScreen*3)/4;
        return CGSizeMake(width, height);
        
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopCategoriesViewCell *cell = (ShopCategoriesViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(_arrTitles.count > 0 && _arrPictures.count > 0) {
        
        NSString *title = [[_arrTitles objectAtIndex: [indexPath row]] uppercaseString];
        NSString *picture = [_arrPictures objectAtIndex: [indexPath row]];
        
        cell.textTitle.text = title;
        
        if(picture.length > 0) {
            
            NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSArray *arrPath =[picture componentsSeparatedByString: @"/"];
            NSString *fileName = [arrPath objectAtIndex:(arrPath.count - 1)];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            
            NSError *attributesError = nil;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&attributesError];
            
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            if(fileExists && fileSize > 1000) {
                
                NSData * data = [NSData dataWithContentsOfFile:filePath];
                if(data) {
                    UIImage *original=[UIImage imageWithData:data];
                    UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:0.1 orientation:original.imageOrientation];
                    cell.imageView.image=small;
                }
            } else {
                
                NSString *pictureUrl = [NSString stringWithFormat:@"%@%@%@", SERVER, UPLOADS, picture];
                NSURL *url = [NSURL URLWithString:pictureUrl];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                 {
                     
                     if(error == nil) {
                         
                         [data writeToFile:filePath atomically:YES];
                         UIImage *original=[UIImage imageWithData:data];
                         UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:1.0 orientation:original.imageOrientation];
                         cell.imageView.image=small;
                         
                     }
                     
                 }];
                
            }
            
        } else {
            cell.imageView.image = [UIImage imageNamed: @"cover.jpg"];
        }
        
        
    }
    
    // Configure the cell
    
    return cell;
}

@end
