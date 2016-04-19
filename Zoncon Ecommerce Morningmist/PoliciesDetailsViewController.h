//
//  PoliciesDetailsViewController.h
//  PNG Diamonds
//
//  Created by Hrushikesh  on 04/02/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

@import Contacts;
@import ContactsUI;
#import <UIKit/UIKit.h>

@interface PoliciesDetailsViewController : UIViewController <NSURLConnectionDelegate, CNContactViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scView;
@property (nonatomic, strong) NSString *idSrvStream;
@property (nonatomic, strong) NSString *idSrvItem;


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
