//
//  PoliciesListCollectionViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 04/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "globals.h"
#import "DbHelper.h"
#import "NavigationViewController.h"
#import "SyncViewController.h"
#import "PoliciesListCollectionViewCell.h"
#import "PoliciesDetailsViewController.h"
#import "PoliciesListCollectionViewController.h"

@interface PoliciesListCollectionViewController ()

@end

@implementation PoliciesListCollectionViewController

static NSString * const reuseIdentifier = @"PoliciesList";

@synthesize arrTitles = _arrTitles;
@synthesize arrIds = _arrIds;
@synthesize arrSubTitles = _arrSubTitles;
@synthesize _idSrv = __idSrv;

int POLICIES_OFFSET = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
    _arrIds = [[NSMutableArray alloc]init];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
    _arrIds = [[NSMutableArray alloc]init];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    __idSrv = @"";
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
    _arrIds = [[NSMutableArray alloc]init];
    
    [self loadFromLocalDB];
    [self.collectionView reloadData];
    
}

- (void)loadFromLocalDB {
    
    _arrTitles = [[NSMutableArray alloc]init];
    _arrSubTitles = [[NSMutableArray alloc]init];
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
        
        if([[name lowercaseString] rangeOfString:@"terms"].location != NSNotFound) {
            
            _idStream = [cv objectForKey:DB_COL_ID];
            __idSrv = [cv objectForKey:DB_COL_SRV_ID];
            break;
            
        }
        
    }
    
    if(_idStream.length > 0) {
        
        POLICIES_OFFSET = 0;
        
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
            
            POLICIES_OFFSET++;
            
        }
        
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"PoliciesDetails"])
    {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        int rowNo = indexPath.row;
        
        // Get reference to the destination view controller
        PoliciesDetailsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        vc.idSrvStream = __idSrv;
        vc.idSrvItem = [_arrIds objectAtIndex:rowNo];
        
    }
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PoliciesListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if(_arrTitles.count > 0 && _arrSubTitles.count > 0) {
        
        NSString *title = [_arrTitles objectAtIndex: [indexPath row]];
        
        cell.title.text = title;
        cell.title.font = [UIFont systemFontOfSize:FONT_SIZE_LIST_TITLES];
        
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat widthOfScreen  = [[UIScreen mainScreen] bounds].size.width;
    
    CGFloat width = widthOfScreen;
    
    return CGSizeMake(width, 63);
}

@end
