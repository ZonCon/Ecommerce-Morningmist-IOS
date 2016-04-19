//
//  AlertsDetailsViewController.m
//  PNG Diamonds
//
//  Created by Hrushikesh  on 04/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "globals.h"
#import "DbHelper.h"
#import "NavigationViewController.h"
#import "SyncViewController.h"
#import "ImageScreenViewController.h"
#import "AlertsDetailsViewController.h"

@interface AlertsDetailsViewController ()

@end

@implementation AlertsDetailsViewController

@synthesize scView = _scView;
@synthesize idSrvItem = _idSrvItem;
@synthesize idSrvStream = _idSrvStream;
@synthesize currUrl = _currUrl;
@synthesize arrUrls = _arrUrls;
@synthesize arrLocations = _arrLocations;
@synthesize arrContacts = _arrContacts;
@synthesize arrAttachments = _arrAttachments;
@synthesize strSub = _strSub;
@synthesize strTitle = _strTitle;
@synthesize strContent = _strContent;
@synthesize streamName = _streamName;
@synthesize discount = _discount;
@synthesize imgUrl = _imgUrl;
@synthesize itemBooking = _itemBooking;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _currUrl = @"";
    _imgUrl = @"";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *myContentView;
    myContentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    
    [_scView addSubview:myContentView];
    
    int topY = 0;
    
    
    UIFont *titleFont = [UIFont systemFontOfSize:FONT_SIZE_DETAIL_TITLE];
    UIFont *subFont = [UIFont systemFontOfSize:FONT_SIZE_DETAIL_DESC];
    UIFont *contentFont = [UIFont systemFontOfSize:FONT_SIZE_DETAIL_CONTENT];
    UIColor *grayColor = [UIColor colorWithRed:(150.0/255.0) green:(150.0/255.0) blue:(150.0/255.0) alpha:1.0];
    
    NSDictionary *cv = @{
                         DB_COL_TYPE: DB_STREAM_TYPE_MESSAGE,
                         DB_COL_SRV_ID: _idSrvStream
                         };
    NSMutableArray *arr = [[DbHelper getSharedInstance] retrieveRecords:cv];
    
    for(int i = 0; i < arr.count; i++) {
        
        NSDictionary *cvStreams = arr[i];
        NSString *title = [cvStreams objectForKey:DB_COL_NAME];
        NSString *_idStream = [cvStreams objectForKey:DB_COL_ID];
        
        _streamName = title;
        
        //Find items belonging to the stream
        cv = @{
               DB_COL_TYPE: DB_RECORD_TYPE_ITEM,
               DB_COL_SRV_ID: _idSrvItem,
               DB_COL_FOREIGN_KEY: _idStream
               };
        
        NSMutableArray *arrItems = [[DbHelper getSharedInstance] retrieveRecords:cv];
        for(int j = 0; j < arrItems.count; j++) {
            
            NSDictionary *cvItems = [arrItems objectAtIndex:j
                                     ];
            NSString *_idItem = [cvItems objectForKey:DB_COL_ID];
            NSString *itemTitle = [cvItems objectForKey:DB_COL_TITLE];
            _strTitle = itemTitle;
            NSString *itemSubtitle = [cvItems objectForKey:DB_COL_SUBTITLE];
            _strSub = itemSubtitle;
            NSString *itemContent = [cvItems objectForKey:DB_COL_CONTENT];
            _strContent = itemContent;
            itemContent = [itemContent stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
            NSString *itemTime = [cvItems objectForKey:DB_COL_TIMESTAMP];
            NSString *picture1 = @"";
            NSTimeInterval _interval=[itemTime doubleValue]/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
            [_formatter setDateFormat:@"dd/MM/yy hh:mm"];
            itemTime = [_formatter stringFromDate:date];
            _strTimestamp = itemTime;
            
            self.navigationItem.title = [itemTitle uppercaseString];
            
            int unknownOffset = 3;
            int maxWidth = screenWidth;
            int margin = 20, width = screenWidth - margin*2;
            
            topY = margin;
            
            //Find pictures belonging to the item of the stream
            cv = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_PICTURE,
                   DB_COL_FOREIGN_KEY: _idItem
                   };
            
            NSMutableArray *arrPictures_1 = [[DbHelper getSharedInstance] retrieveRecords:cv];
            
            NSLog(@"Pictures found = %d", arrPictures_1.count);
            
            if(arrPictures_1.count > 0) {
                
                NSDictionary *cvPictures = [arrPictures_1 objectAtIndex:0];
                picture1 = [cvPictures objectForKey:DB_COL_PATH_PROC];
                _imgUrl = [cvPictures objectForKey:DB_COL_PATH_ORIG];
                
            }
            
            NSLog(@"Max width = %d", width);
            
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(margin + unknownOffset, topY + 5, width, 100)];
            labelTitle.backgroundColor = [UIColor clearColor];
            labelTitle.textAlignment = NSTextAlignmentLeft;
            labelTitle.text = itemTitle;
            labelTitle.numberOfLines = 0;
            labelTitle.textColor = TEXT_COLOR;
            labelTitle.font = titleFont;
            [labelTitle sizeToFit];
            labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
            [myContentView addSubview:labelTitle];
            topY = (labelTitle.frame.origin.y + labelTitle.frame.size.height);
            
            UIImageView *imageView;
            if(picture1.length > 0) {
                
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin + unknownOffset, topY + margin, width, (width*3)/4)];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                imageView.backgroundColor = [UIColor blackColor];
                [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
                [imageView.layer setBorderWidth: 1.0];
                imageView.image = [UIImage imageNamed:@"app_icon"];
                [myContentView addSubview:imageView];
                
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnImage:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                [imageView addGestureRecognizer:tapGestureRecognizer];
                imageView.userInteractionEnabled = YES;
                
                NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSArray *arrPath =[picture1 componentsSeparatedByString: @"/"];
                NSString *fileName = [arrPath objectAtIndex:(arrPath.count - 1)];
                NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                
                NSError *attributesError = nil;
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&attributesError];
                if(fileExists && [fileAttributes fileSize] > 1000) {
                    
                    NSData * data = [NSData dataWithContentsOfFile:filePath];
                    //NSLog(@"Displaying picture=%@", filePath);
                    if(data) {
                        UIImage *original=[UIImage imageWithData:data];
                        UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:0.5 orientation:original.imageOrientation];
                        imageView.image=small;
                    }
                    
                } else {
                    
                    NSString *pictureUrl = [NSString stringWithFormat:@"%@%@%@", SERVER, UPLOADS, picture1];
                    //NSLog(@"Downloading picture=%@", pictureUrl);
                    NSURL *url = [NSURL URLWithString:pictureUrl];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
                     {
                         
                         if(error == nil) {
                             
                             [data writeToFile:filePath atomically:YES];
                             UIImage *original=[UIImage imageWithData:data];
                             UIImage *small = [UIImage imageWithCGImage:original.CGImage scale:0.5 orientation:original.imageOrientation];
                             imageView.image=small;
                             
                         }
                         
                     }];
                    
                }
                topY = (imageView.frame.origin.y + imageView.frame.size.height);
                
            }
            
            topY += (20 + margin);
            
            if(itemSubtitle.length > 0) {
                UILabel *labelSub = [[UILabel alloc] initWithFrame:CGRectMake(margin + unknownOffset, topY, width, 0)];
                labelSub.backgroundColor = [UIColor clearColor];
                labelSub.textAlignment = NSTextAlignmentLeft;
                labelSub.text = itemSubtitle;
                labelSub.numberOfLines = 0;
                labelSub.textColor = TEXT_COLOR;
                labelSub.font = subFont;
                [labelSub sizeToFit];
                labelSub.lineBreakMode = NSLineBreakByWordWrapping;
                [myContentView addSubview:labelSub];
                topY = (labelSub.frame.origin.y + labelSub.frame.size.height + margin);
                
            }
            
             UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, width, 0)];
             labelTime.backgroundColor = [UIColor clearColor];
             labelTime.textAlignment = NSTextAlignmentLeft;
             labelTime.text = itemTime;
             labelTime.numberOfLines = 0;
             labelTime.textColor = grayColor;
             labelTime.font = subFont;
             [labelTime sizeToFit];
             labelTime.lineBreakMode = NSLineBreakByWordWrapping;
             [myContentView addSubview:labelTime];
             topY = (labelTime.frame.origin.y + labelTime.frame.size.height + margin);
            
            UIImageView *imageShare;
            imageShare = [[UIImageView alloc] initWithFrame:CGRectMake(margin + unknownOffset, topY, 30, 30)];
            imageShare.contentMode = UIViewContentModeScaleAspectFit;
            imageShare.clipsToBounds = YES;
            imageShare.image = [UIImage imageNamed:@"share.png"];
            topY = (imageShare.frame.origin.y + imageShare.frame.size.height + margin);
            [myContentView addSubview:imageShare];
            imageShare.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGestureRecognizer_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnShare:)];
            tapGestureRecognizer_2.numberOfTapsRequired = 1;
            [imageShare addGestureRecognizer:tapGestureRecognizer_2];
            imageShare.userInteractionEnabled = YES;
            
            if(itemContent.length > 0) {
                UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(margin + unknownOffset, topY, width, 0)];
                labelContent.backgroundColor = [UIColor clearColor];
                labelContent.textAlignment = NSTextAlignmentLeft;
                labelContent.text = itemContent;
                labelContent.numberOfLines = 0;
                labelContent.textColor = TEXT_COLOR;
                labelContent.font = contentFont;
                [labelContent sizeToFit];
                labelContent.lineBreakMode = NSLineBreakByWordWrapping;
                [myContentView addSubview:labelContent];
                topY = (labelContent.frame.origin.y + labelContent.frame.size.height + margin);
            }
            
            //Find pictures belonging to the item of the stream
            cv = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_URL,
                   DB_COL_FOREIGN_KEY: _idItem
                   };
            
            _arrUrls = [[NSMutableArray alloc]init];
            NSMutableArray *arrUrls_1 = [[DbHelper getSharedInstance] retrieveRecords:cv];
            //NSLog(@"URLs = %d", arrUrls_1.count);
            for(int k = 0; k < arrUrls_1.count; k++) {
                
                NSDictionary *cvUrls = [arrUrls_1 objectAtIndex:k];
                NSString *caption = [cvUrls objectForKey:DB_COL_CAPTION];
                NSString *url = [cvUrls objectForKey:DB_COL_URL];
                
                [_arrUrls addObject:url];
                
                UILabel *labelLink = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, (maxWidth - margin*2), 20)];
                labelLink.backgroundColor = [UIColor clearColor];
                labelLink.textAlignment = NSTextAlignmentLeft;
                labelLink.text = [NSString stringWithFormat:@"[ Link: %@ ]", caption];
                labelLink.numberOfLines = 0;
                labelLink.textColor = TEXT_COLOR;
                labelLink.font = contentFont;
                labelLink.tag = k;
                labelLink.lineBreakMode = NSLineBreakByWordWrapping;
                [myContentView addSubview:labelLink];
                topY = (labelLink.frame.origin.y + labelLink.frame.size.height + margin);
                
                UITapGestureRecognizer *tapGestureRecognizerUrl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnUrl:)];
                tapGestureRecognizerUrl.numberOfTapsRequired = 1;
                [labelLink addGestureRecognizer:tapGestureRecognizerUrl];
                labelLink.userInteractionEnabled = YES;
                
            }
            
            //Find pictures belonging to the item of the stream
            cv = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_LOCATION,
                   DB_COL_FOREIGN_KEY: _idItem
                   };
            
            _arrLocations = [[NSMutableArray alloc]init];
            NSMutableArray *arrLocations_1 = [[DbHelper getSharedInstance] retrieveRecords:cv];
            //NSLog(@"Locations = %d", arrLocations_1.count);
            for(int k = 0; k < arrLocations_1.count; k++) {
                
                NSDictionary *cvLocations = [arrLocations_1 objectAtIndex:k];
                NSString *caption = [cvLocations objectForKey:DB_COL_CAPTION];
                NSString *latlon = [cvLocations objectForKey:DB_COL_LOCATION];
                
                [_arrLocations addObject:latlon];
                
                UILabel *labelLocation = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, (maxWidth - margin*2), 20)];
                labelLocation.backgroundColor = [UIColor clearColor];
                labelLocation.textAlignment = NSTextAlignmentLeft;
                labelLocation.text = [NSString stringWithFormat:@"[ View on Map: %@ ]", caption];
                labelLocation.numberOfLines = 0;
                labelLocation.textColor = [UIColor brownColor];
                labelLocation.font = contentFont;
                labelLocation.tag = k;
                labelLocation.lineBreakMode = NSLineBreakByWordWrapping;
                [myContentView addSubview:labelLocation];
                topY = (labelLocation.frame.origin.y + labelLocation.frame.size.height + margin);
                
                labelLocation.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGestureRecognizer_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnMap:)];
                tapGestureRecognizer_1.numberOfTapsRequired = 1;
                [labelLocation addGestureRecognizer:tapGestureRecognizer_1];
                labelLocation.userInteractionEnabled = YES;
                
            }
            
            //Find pictures belonging to the item of the stream
            cv = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_ATTACHMENT,
                   DB_COL_FOREIGN_KEY: _idItem
                   };
            
            _arrAttachments = [[NSMutableArray alloc]init];
            NSMutableArray *arrAttachments_1 = [[DbHelper getSharedInstance] retrieveRecords:cv];
            for(int k = 0; k < arrAttachments_1.count; k++) {
                
                NSDictionary *cvAttachments = [arrAttachments_1 objectAtIndex:k];
                NSString *caption = [cvAttachments objectForKey:DB_COL_CAPTION];
                NSString *url = [cvAttachments objectForKey:DB_COL_URL];
                
                [_arrAttachments addObject:url];
                
                UILabel *labelAttachment = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, (maxWidth - margin*2), 20)];
                labelAttachment.backgroundColor = [UIColor clearColor];
                labelAttachment.textAlignment = NSTextAlignmentLeft;
                labelAttachment.text = [NSString stringWithFormat:@"[ Attachment: %@ ]", caption];
                labelAttachment.numberOfLines = 0;
                labelAttachment.textColor = [UIColor redColor];
                labelAttachment.font = contentFont;
                labelAttachment.tag = k;
                labelAttachment.lineBreakMode = NSLineBreakByWordWrapping;
                [myContentView addSubview:labelAttachment];
                topY = (labelAttachment.frame.origin.y + labelAttachment.frame.size.height + margin);
                
                labelAttachment.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGestureRecognizer_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnAttachment:)];
                tapGestureRecognizer_1.numberOfTapsRequired = 1;
                [labelAttachment addGestureRecognizer:tapGestureRecognizer_1];
                labelAttachment.userInteractionEnabled = YES;
                
            }
            
            //Find pictures belonging to the item of the stream
            cv = @{
                   DB_COL_TYPE: DB_RECORD_TYPE_CONTACT,
                   DB_COL_FOREIGN_KEY: _idItem
                   };
            _arrContacts = [[NSMutableArray alloc]init];
            NSMutableArray *arrContacts_1 = [[DbHelper getSharedInstance] retrieveRecords:cv];
            //NSLog(@"Contacts = %d", arrContacts_1.count);
            for(int k = 0; k < arrContacts_1.count; k++) {
                
                NSDictionary *cvContacts = [arrContacts_1 objectAtIndex:k];
                NSString *name = [cvContacts objectForKey:DB_COL_NAME];
                
                [_arrContacts addObject:cvContacts];
                
                UILabel *labelContacts = [[UILabel alloc] initWithFrame:CGRectMake(margin, topY, (maxWidth - margin*2), 20)];
                labelContacts.backgroundColor = [UIColor clearColor];
                labelContacts.textAlignment = NSTextAlignmentLeft;
                labelContacts.text = [NSString stringWithFormat:@"[ Contact: %@ ]", name];
                labelContacts.numberOfLines = 0;
                labelContacts.textColor = [UIColor purpleColor];
                labelContacts.font = contentFont;
                labelContacts.tag = k;
                labelContacts.lineBreakMode = NSLineBreakByWordWrapping;
                [myContentView addSubview:labelContacts];
                topY = (labelContacts.frame.origin.y + labelContacts.frame.size.height + margin);
                
                labelContacts.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGestureRecognizer_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnContacts:)];
                tapGestureRecognizer_1.numberOfTapsRequired = 1;
                [labelContacts addGestureRecognizer:tapGestureRecognizer_1];
                labelContacts.userInteractionEnabled = YES;
                
            }
            
            [myContentView setFrame:CGRectMake(0, 0, maxWidth, topY + 50)];
            _scView.contentSize = CGSizeMake(maxWidth, topY + 50);
            
        }
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    IS_OPENED_FROM_DETAIL = false;
    //NSLog(@"Opneed fro detail = %d", IS_OPENED_FROM_DETAIL);
    
}

- (void)userTappedOnImage:(UIGestureRecognizer*)gestureRecognizer;
{
    
    ImageScreenViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"ImageVc"];
    vc.image = _imgUrl;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)userTappedOnContacts:(UIGestureRecognizer*)gestureRecognizer;
{
    
    IS_OPENED_FROM_DETAIL = true;
    
    UILabel *label = (UILabel *)gestureRecognizer.view;
    if(_arrContacts.count > 0) {
        
        NSDictionary *cv = [_arrContacts objectAtIndex:label.tag];
        NSString *name = [cv objectForKey:DB_COL_NAME];
        NSString *email = [cv objectForKey:DB_COL_EMAIL];
        NSString *phone = [cv objectForKey:DB_COL_PHONE];
        IS_OPENED_FROM_DETAIL = true;
        
        CNContactStore *store = [[CNContactStore alloc] init];
        
        // create contact
        
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.givenName = name;
        
        CNLabeledValue *homePhone = [CNLabeledValue labeledValueWithLabel:@"Phone Number" value:[CNPhoneNumber phoneNumberWithStringValue:phone]];
        contact.phoneNumbers = @[homePhone];
        
        CNLabeledValue *homeEmail = [CNLabeledValue labeledValueWithLabel:@"Email Address" value:email];
        contact.emailAddresses = @[homeEmail];
        
        CNContactViewController *controller = [CNContactViewController viewControllerForUnknownContact:contact];
        controller.contactStore = store;
        controller.delegate = self;
        
        [self.navigationController pushViewController:controller animated:TRUE];
        
    }
    
}

- (void)userTappedOnMap:(UIGestureRecognizer*)gestureRecognizer;
{
    
    UILabel *label = (UILabel *)gestureRecognizer.view;
    NSString *location = [_arrLocations objectAtIndex:label.tag];
    location = [location stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *url = [NSString stringWithFormat:@"https://www.google.com/maps?q=%@", location];
    if(_arrLocations.count > 0) {
        IS_OPENED_FROM_DETAIL = true;
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
    }
}

- (void)userTappedOnAttachment:(UIGestureRecognizer*)gestureRecognizer;
{
    UILabel *label = (UILabel *)gestureRecognizer.view;
    NSString *url = [_arrAttachments objectAtIndex:label.tag];
    if(_arrAttachments.count > 0) {
        IS_OPENED_FROM_DETAIL = true;
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
    }
}

- (void)userTappedOnUrl:(UIGestureRecognizer*)gestureRecognizer;
{
    
    UILabel *label = (UILabel *)gestureRecognizer.view;
    NSString *url = [_arrUrls objectAtIndex:label.tag];
    if(_arrUrls.count > 0) {
        IS_OPENED_FROM_DETAIL = true;
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
    }
}

- (void)userTappedOnShare:(UIGestureRecognizer*)gestureRecognizer;
{
    
    IS_OPENED_FROM_DETAIL = true;
    NSString *sharedMsg=[NSString stringWithFormat:@"%@\n%@\nPublished on: %@\n%@", _strTitle, _strSub, _strTimestamp, _strContent];
    NSArray* sharedObjects=[NSArray arrayWithObjects:sharedMsg, nil];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:sharedObjects applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

@end
