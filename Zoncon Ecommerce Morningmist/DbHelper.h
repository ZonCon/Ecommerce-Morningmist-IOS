//
//  DbHelper.h
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 30/10/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface DbHelper : NSObject
{
    NSString *databasePath;
}
+(DbHelper*)getSharedInstance;
-(BOOL)createDB;
-(void) printDB;
-(void) clearDB;
-(void) clearDynamicDataFromDB;
-(void) cleanPictures;
-(BOOL) insertRecord: (NSDictionary *)contentRecord;
-(BOOL) deleteRecord: (NSDictionary *)contentRecord;
-(BOOL) updateRecord: (NSDictionary *)contentRecord whereRecord:(NSDictionary *)whereRecord;
-(NSMutableArray *) retrieveDB;
-(NSMutableArray *)retrieveRecords: (NSDictionary *)contentRecord;
-(NSString *) retrieve_id: (NSDictionary *)contentRecord;

@end
