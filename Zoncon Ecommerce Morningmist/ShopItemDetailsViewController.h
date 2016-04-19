//
//  AbsWorldDetailsViewController.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 16/11/15.
//  Copyright © 2015 MeGo Technologies. All rights reserved.
//

@import Contacts;
@import ContactsUI;
#import <UIKit/UIKit.h>

@interface ShopItemDetailsViewController : UIViewController <NSURLConnectionDelegate, CNContactViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scView;
@property (nonatomic, strong) NSString *idSrvStream;
@property (nonatomic, strong) NSString *idSrvItem;
@property (nonatomic, strong) NSString *selfieType;
@property (nonatomic, strong) NSString *designType;

@property (nonatomic, strong) NSString *currUrl;
@property (nonatomic, strong) NSMutableArray *arrUrls;
@property (nonatomic, strong) NSMutableArray *arrLocations;
@property (nonatomic, strong) NSMutableArray *arrContacts;
@property (nonatomic, strong) NSMutableArray *arrAttachments;

@property (nonatomic, strong) NSString *strTitle;
@property (nonatomic, strong) NSString *strSub;
@property (nonatomic, strong) NSString *strContent;
@property (nonatomic, strong) NSString *strTimestamp;

@property (nonatomic, strong) NSString *streamName;
@property (nonatomic, strong) NSString *discount;
@property (nonatomic, strong) NSString *itemBooking;

@property (nonatomic, strong) NSString *imgUrl;

@end
