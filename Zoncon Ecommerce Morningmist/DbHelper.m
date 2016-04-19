//
//  DbHelper.m
//  Abs Fitness Express
//
//  Created by Hrushikesh  on 30/10/15.
//  Copyright (c) 2015 MeGo Technologies. All rights reserved.
//

#import <sqlite3.h>
#import "globals.h"
#import "DbHelper.h"

@implementation DbHelper

static DbHelper *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


+(DbHelper*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: DB_FILENAME]];
    
    
    BOOL isSuccess = YES;
    //This is purposefully commented
    //if ([filemgr fileExistsAtPath: databasePath ] == NO)
    //{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        char *errMsg;
        
        
        NSString * sqlStmt = [NSString stringWithFormat:@"create table if not exists %@ (%@ integer primary key,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text,%@ text);drop table %@ if exists; ",
                              DB_CURR_TABLENAME,
                              DB_COL_ID,
                              DB_COL_SRV_ID,
                              DB_COL_TYPE,
                              DB_COL_TITLE,
                              DB_COL_SUBTITLE,
                              DB_COL_CONTENT,
                              DB_COL_TIMESTAMP,
                              DB_COL_STOCK,
                              DB_COL_PRICE,
                              DB_COL_EXTRA_1,
                              DB_COL_EXTRA_2,
                              DB_COL_EXTRA_3,
                              DB_COL_EXTRA_4,
                              DB_COL_EXTRA_5,
                              DB_COL_EXTRA_6,
                              DB_COL_EXTRA_7,
                              DB_COL_EXTRA_8,
                              DB_COL_EXTRA_9,
                              DB_COL_EXTRA_10,
                              DB_COL_WEIGHT,
                              DB_COL_BOOKING,
                              DB_COL_DISCOUNT,
                              DB_COL_SKU,
                              DB_COL_SIZE,
                              DB_COL_EXTRA_WEIGHT,
                              DB_COL_NAME,
                              DB_COL_CAPTION,
                              DB_COL_URL,
                              DB_COL_LOCATION,
                              DB_COL_EMAIL,
                              DB_COL_PHONE,
                              DB_COL_PATH_ORIG,
                              DB_COL_PATH_PROC,
                              DB_COL_PATH_TH,
                              DB_COL_CART_ITEM_STREAM_ID,
                              DB_COL_CART_ITEM_ITEM_ID,
                              DB_COL_CART_ITEM_QUANTITY,
                              DB_COL_CART_COUPON_CODE,
                              DB_COL_CART_ISOPEN,
                              DB_COL_BRANCHINBOXSTREAM_ID,
                              DB_COL_BRANCHINBOXITEM_ID,
                              DB_COL_BRANCHSTREAM_ID,
                              DB_COL_BRANCHITEM_ID,
                              DB_COL_MEMBERINBOXSTREAM_ID,
                              DB_COL_MEMBERINBOXITEM_ID,
                              DB_COL_FOREIGN_KEY,
                              DB_COL_STREAM_ID,
                              DB_COL_ITEM_ID,
                              DB_OLD_TABLENAME];
        
        
        ////NSLog(sqlStmt);
        const char *sql_stmt = [sqlStmt UTF8String];
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
            != SQLITE_OK)
        {
            //NSLog(@"Database created failure ");
            isSuccess = NO;
        }
        
        //NSLog(@"Database created successfully");
        sqlite3_close(database);
        return  isSuccess;
    }
    else {
        isSuccess = NO;
    }
    //}
    return isSuccess;
}

-(BOOL) deleteRecord:(NSDictionary *)contentRecord;
{
    
    BOOL retval = NO;
    
    NSArray* keys=[contentRecord allKeys];
    NSArray* values=[contentRecord allValues];
    
    NSString *querySQL = [NSString stringWithFormat:@"delete from %@ where ", DB_CURR_TABLENAME];
    for(int i = 0; i < (keys.count); i++) {
        
        if(i == (keys.count - 1)) {
            querySQL = [NSString stringWithFormat:@"%@%@ = '%@'", querySQL, keys[i], values[i]];
        } else {
            querySQL = [NSString stringWithFormat:@"%@%@ = '%@' and ",querySQL, keys[i], values[i]];
        }
        
    }
    
    //NSLog(querySQL);
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Update successful");
            retval = YES;
        }
        else {
            //NSLog(@"Update not successful");
            retval = NO;
        }
        
        sqlite3_reset(statement);
        
    }
    
    sqlite3_close(database);
    
    
    return retval;
    
}

-(BOOL) insertRecord: (NSDictionary *)contentRecord;
{
    
    BOOL retval = NO;
    
    NSArray* keys=[contentRecord allKeys];
    NSArray* values=[contentRecord allValues];
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into %@ (", DB_CURR_TABLENAME];
        
        for(int i = 0; i < (keys.count); i++) {
            
            if(i == (keys.count - 1)) {
                insertSQL = [NSString stringWithFormat:@"%@%@", insertSQL, keys[i]];
            } else {
                insertSQL = [NSString stringWithFormat:@"%@%@,", insertSQL, keys[i]];
            }
            
        }
        insertSQL = [NSString stringWithFormat:@"%@) values (", insertSQL];
        //NSLog(insertSQL);
        for(int i = 0; i < (values.count); i++) {
            
            if(i == (values.count - 1)) {
                insertSQL = [NSString stringWithFormat:@"%@'%@'", insertSQL, [values[i] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
            } else {
                insertSQL = [NSString stringWithFormat:@"%@'%@',", insertSQL, [values[i] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
            }
            //NSLog(insertSQL);
        }
        insertSQL = [NSString stringWithFormat:@"%@);", insertSQL];
        
       // //NSLog(insertSQL);
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Insert successful");
            retval = YES;
        }
        else {
            //NSLog(@"Insert failed %d", success);
            retval = NO;
        }
        
        sqlite3_reset(statement);
        
    }
    
    sqlite3_close(database);
    
    return retval;
    
}

-(NSString *) retrieve_id: (NSDictionary *)contentRecord;
{
    
    NSString *retVal = @"";
    
    NSArray* keys=[contentRecord allKeys];
    NSArray* values=[contentRecord allValues];
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *querySQL = [NSString stringWithFormat:@"select * from %@ where ", DB_CURR_TABLENAME];
        for(int i = 0; i < (keys.count); i++) {
            
            if(i == (keys.count - 1)) {
                querySQL = [NSString stringWithFormat:@"%@%@ = '%@';", querySQL, keys[i], values[i]];
            } else {
                querySQL = [NSString stringWithFormat:@"%@%@ = '%@' and ",querySQL, keys[i], values[i]];
            }
            
        }
        
        ////NSLog(querySQL);
        
        
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                
                if((const char *) sqlite3_column_text(statement, 0) != NULL) {
                    retVal = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                }
                
            }
            sqlite3_reset(statement);
        }
        
        sqlite3_close(database);
        
    }
    
    return retVal;
    
}

-(NSMutableArray *) retrieveDB;
{
    
    NSMutableArray *allRows = [[NSMutableArray alloc] init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select * from %@", DB_CURR_TABLENAME];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                ////NSLog(@"Columns %d", sqlite3_data_count(statement));
                NSString *_id = @"", *srv_id = @"", *type = @"", *title = @"", *subtitle = @"", *content = @"", *timestamp = @"", *stock = @"", *price = @"", *extra1 = @"", *extra2 = @"", *extra3 = @"", *extra4 = @"", *extra5 = @"", *extra6 = @"", *extra7 = @"", *extra8 = @"", *extra9 = @"", *extra10 = @"", *weight = @"", *booking = @"", *discount = @"", *sku = @"", *size = @"", *name =@"", *caption = @"", *url = @"", *location = @"", *email = @"", *phone = @"", *path_orig = @"", *path_proc = @"", *path_th = @"", *cart_item_stream_id = @"", *cart_item_item_id = @"", *cart_item_quantity =@"", *cart_coupon_code = @"", *cart_isopen = @"", *branchinboxstream_id = @"", *branchinboxitem_id = @"", *branchstream_id = @"", *branchitem_id = @"", *memberinboxstream_id = @"", *memberinboxitem_id = @"", *foreign_key = @"", *stream_id = @"", *item_id = @"";
                
                if((const char *) sqlite3_column_text(statement, 0) != NULL)
                    _id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                
                if((const char *) sqlite3_column_text(statement, 1) != NULL)
                    srv_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                if((const char *) sqlite3_column_text(statement, 2) != NULL)
                    type = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                
                if((const char *) sqlite3_column_text(statement, 3) != NULL)
                    title =  [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                
                if((const char *) sqlite3_column_text(statement, 4) != NULL)
                    subtitle = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                
                if((const char *) sqlite3_column_text(statement, 5) != NULL)
                    content = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                
                if((const char *) sqlite3_column_text(statement, 6) != NULL)
                    timestamp = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                
                if((const char *) sqlite3_column_text(statement, 7) != NULL)
                    stock = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                
                if((const char *) sqlite3_column_text(statement, 8) != NULL)
                    price = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                
                if((const char *) sqlite3_column_text(statement, 9) != NULL)
                    extra1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                
                if((const char *) sqlite3_column_text(statement, 10) != NULL)
                    extra2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                
                if((const char *) sqlite3_column_text(statement, 11) != NULL)
                    extra3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                
                if((const char *) sqlite3_column_text(statement, 12) != NULL)
                    extra4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                
                if((const char *) sqlite3_column_text(statement, 13) != NULL)
                    extra5 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                
                if((const char *) sqlite3_column_text(statement, 14) != NULL)
                    extra6 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                
                if((const char *) sqlite3_column_text(statement, 15) != NULL)
                    extra7 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                
                if((const char *) sqlite3_column_text(statement, 16) != NULL)
                    extra8 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                
                if((const char *) sqlite3_column_text(statement, 17) != NULL)
                    extra9 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                
                if((const char *) sqlite3_column_text(statement, 18) != NULL)
                    extra10 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)];
                
                if((const char *) sqlite3_column_text(statement, 19) != NULL)
                    weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)];
                
                if((const char *) sqlite3_column_text(statement, 20) != NULL)
                    booking = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)];
                
                if((const char *) sqlite3_column_text(statement, 21) != NULL)
                    discount = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)];
                
                if((const char *) sqlite3_column_text(statement, 22) != NULL)
                    sku = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)];
                
                if((const char *) sqlite3_column_text(statement, 23) != NULL)
                    size = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)];
                
                if((const char *) sqlite3_column_text(statement, 24) != NULL)
                    weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)];
                
                if((const char *) sqlite3_column_text(statement, 25) != NULL)
                    name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 25)];
                
                if((const char *) sqlite3_column_text(statement, 26) != NULL)
                    caption = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 26)];
                
                if((const char *) sqlite3_column_text(statement, 27) != NULL)
                    url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 27)];
                
                if((const char *) sqlite3_column_text(statement, 28) != NULL)
                    location = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 28)];
                
                if((const char *) sqlite3_column_text(statement, 29) != NULL)
                    email = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 29)];
                
                if((const char *) sqlite3_column_text(statement, 30) != NULL)
                    phone = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 30)];
                
                if((const char *) sqlite3_column_text(statement, 31) != NULL)
                    path_orig = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 31)]
                    ;
                if((const char *) sqlite3_column_text(statement, 32) != NULL)
                    path_proc = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 32)];
                
                if((const char *) sqlite3_column_text(statement, 33) != NULL)
                    path_th = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 33)];
                
                if((const char *) sqlite3_column_text(statement, 34) != NULL)
                    cart_item_stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 34)];
                
                if((const char *) sqlite3_column_text(statement, 35) != NULL)
                    cart_item_item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 35)];
                
                if((const char *) sqlite3_column_text(statement, 36) != NULL)
                    cart_item_quantity = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 36)];
                
                if((const char *) sqlite3_column_text(statement, 37) != NULL)
                    cart_coupon_code = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 37)];
                
                if((const char *) sqlite3_column_text(statement, 38) != NULL)
                    cart_isopen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 38)];
                
                if((const char *) sqlite3_column_text(statement, 39) != NULL)
                    branchinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 39)];
                
                if((const char *) sqlite3_column_text(statement, 40) != NULL)
                    branchinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 40)];
                
                if((const char *) sqlite3_column_text(statement, 41) != NULL)
                    branchstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 41)];
                
                if((const char *) sqlite3_column_text(statement, 42) != NULL)
                    branchitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 42)];
                
                if((const char *) sqlite3_column_text(statement, 43) != NULL)
                    memberinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 43)];
                
                if((const char *) sqlite3_column_text(statement, 44) != NULL)
                    memberinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 44)];
                
                if((const char *) sqlite3_column_text(statement, 45) != NULL)
                    foreign_key = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 45)];
                
                if((const char *) sqlite3_column_text(statement, 46) != NULL)
                    stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 46)];
                
                if((const char *) sqlite3_column_text(statement, 47) != NULL)
                    item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 47)];
                
                NSDictionary *contentValues = @{
                                                DB_COL_ID: _id,
                                                DB_COL_SRV_ID: srv_id,
                                                DB_COL_TYPE: type,
                                                DB_COL_TITLE: title,
                                                DB_COL_SUBTITLE: subtitle,
                                                DB_COL_CONTENT: content,
                                                DB_COL_TIMESTAMP: timestamp,
                                                DB_COL_STOCK: stock,
                                                DB_COL_PRICE: price,
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
                                                DB_COL_WEIGHT: weight,
                                                DB_COL_BOOKING: booking,
                                                DB_COL_DISCOUNT: discount,
                                                DB_COL_SKU: sku,
                                                DB_COL_SIZE: size,
                                                DB_COL_EXTRA_WEIGHT: weight,
                                                DB_COL_NAME: name,
                                                DB_COL_CAPTION: caption,
                                                DB_COL_URL: url,
                                                DB_COL_LOCATION: location,
                                                DB_COL_EMAIL: email,
                                                DB_COL_PHONE: phone,
                                                DB_COL_PATH_ORIG: path_orig,
                                                DB_COL_PATH_PROC: path_proc,
                                                DB_COL_PATH_TH: path_th,
                                                DB_COL_CART_ITEM_STREAM_ID: cart_item_stream_id,
                                                DB_COL_CART_ITEM_ITEM_ID: cart_item_item_id,
                                                DB_COL_CART_ITEM_QUANTITY: cart_item_quantity,
                                                DB_COL_CART_COUPON_CODE: cart_coupon_code,
                                                DB_COL_CART_ISOPEN: cart_isopen,
                                                DB_COL_BRANCHINBOXSTREAM_ID: branchinboxstream_id,
                                                DB_COL_BRANCHINBOXITEM_ID: branchinboxitem_id,
                                                DB_COL_BRANCHSTREAM_ID: branchstream_id,
                                                DB_COL_BRANCHITEM_ID: branchitem_id,
                                                DB_COL_MEMBERINBOXSTREAM_ID: memberinboxstream_id,
                                                DB_COL_MEMBERINBOXITEM_ID: memberinboxitem_id,
                                                DB_COL_FOREIGN_KEY: foreign_key,
                                                DB_COL_STREAM_ID: stream_id,
                                                DB_COL_ITEM_ID: item_id
                                                };
                [allRows addObject:contentValues];
                
            }
            sqlite3_reset(statement);
            
        }
        sqlite3_close(database);
    }
    
    return allRows;
    
}

-(BOOL) updateRecord: (NSDictionary *)contentRecord whereRecord:(NSDictionary *)whereRecord;
{
    
    BOOL retval = NO;
    
    NSArray* keys=[contentRecord allKeys];
    NSArray* values=[contentRecord allValues];
    
    NSArray* whereKeys=[whereRecord allKeys];
    NSArray* whereValues=[whereRecord allValues];
    
    
    NSString *querySQL = [NSString stringWithFormat:@"update %@ set ", DB_CURR_TABLENAME];
    for(int i = 0; i < (keys.count); i++) {
        
        if(i == (keys.count - 1)) {
            querySQL = [NSString stringWithFormat:@"%@%@ = '%@'", querySQL, keys[i], [values[i] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
        } else {
            querySQL = [NSString stringWithFormat:@"%@%@ = '%@', ",querySQL, keys[i], [values[i] stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
        }
        
    }
    
    querySQL = [NSString stringWithFormat:@"%@ where ",querySQL];
    for(int i = 0; i < (whereKeys.count); i++) {
        
        if(i == (whereKeys.count - 1)) {
            querySQL = [NSString stringWithFormat:@"%@%@ = '%@';", querySQL, whereKeys[i], whereValues[i]];
        } else {
            querySQL = [NSString stringWithFormat:@"%@%@ = '%@' and ",querySQL, whereKeys[i], whereValues[i]];
        }
        
    }
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            //NSLog(@"Update successful");
            retval = YES;
        }
        else {
            retval = NO;
        }
        
        sqlite3_reset(statement);
        
    }
    
    sqlite3_close(database);
    
    return retval;
}

-(NSMutableArray *) retrieveRecords: (NSDictionary *)contentRecord;
{
    NSMutableArray *selRows = [[NSMutableArray alloc] init];
    
    NSArray* keys=[contentRecord allKeys];
    NSArray* values=[contentRecord allValues];
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *querySQL = [NSString stringWithFormat:@"select * from %@ where ", DB_CURR_TABLENAME];
        for(int i = 0; i < (keys.count); i++) {
            
            if(i == (keys.count - 1)) {
                querySQL = [NSString stringWithFormat:@"%@%@ = '%@';", querySQL, keys[i], values[i]];
            } else {
                querySQL = [NSString stringWithFormat:@"%@%@ = '%@' and ",querySQL, keys[i], values[i]];
            }
            
        }
        
       // //NSLog(querySQL);
        
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                ////NSLog(@"Columns %d", sqlite3_data_count(statement));
                NSString *_id = @"", *srv_id = @"", *type = @"", *title = @"", *subtitle = @"", *content = @"", *timestamp = @"", *stock = @"", *price = @"", *extra1 = @"", *extra2 = @"", *extra3 = @"", *extra4 = @"", *extra5 = @"", *extra6 = @"", *extra7 = @"", *extra8 = @"", *extra9 = @"", *extra10 = @"", *weight = @"", *booking = @"", *discount = @"", *sku = @"", *size = @"", *name =@"", *caption = @"", *url = @"", *location = @"", *email = @"", *phone = @"", *path_orig = @"", *path_proc = @"", *path_th = @"", *cart_item_stream_id = @"", *cart_item_item_id = @"", *cart_item_quantity =@"", *cart_coupon_code = @"", *cart_isopen = @"", *branchinboxstream_id = @"", *branchinboxitem_id = @"", *branchstream_id = @"", *branchitem_id = @"", *memberinboxstream_id = @"", *memberinboxitem_id = @"", *foreign_key = @"", *stream_id = @"", *item_id = @"";
                
                if((const char *) sqlite3_column_text(statement, 0) != NULL)
                    _id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                
                if((const char *) sqlite3_column_text(statement, 1) != NULL)
                    srv_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                if((const char *) sqlite3_column_text(statement, 2) != NULL)
                    type = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                
                if((const char *) sqlite3_column_text(statement, 3) != NULL)
                    title =  [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                
                if((const char *) sqlite3_column_text(statement, 4) != NULL)
                    subtitle = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                
                if((const char *) sqlite3_column_text(statement, 5) != NULL)
                    content = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                
                if((const char *) sqlite3_column_text(statement, 6) != NULL)
                    timestamp = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                
                if((const char *) sqlite3_column_text(statement, 7) != NULL)
                    stock = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                
                if((const char *) sqlite3_column_text(statement, 8) != NULL)
                    price = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                
                if((const char *) sqlite3_column_text(statement, 9) != NULL)
                    extra1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                
                if((const char *) sqlite3_column_text(statement, 10) != NULL)
                    extra2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                
                if((const char *) sqlite3_column_text(statement, 11) != NULL)
                    extra3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                
                if((const char *) sqlite3_column_text(statement, 12) != NULL)
                    extra4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                
                if((const char *) sqlite3_column_text(statement, 13) != NULL)
                    extra5 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                
                if((const char *) sqlite3_column_text(statement, 14) != NULL)
                    extra6 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                
                if((const char *) sqlite3_column_text(statement, 15) != NULL)
                    extra7 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                
                if((const char *) sqlite3_column_text(statement, 16) != NULL)
                    extra8 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                
                if((const char *) sqlite3_column_text(statement, 17) != NULL)
                    extra9 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                
                if((const char *) sqlite3_column_text(statement, 18) != NULL)
                    extra10 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)];
                
                if((const char *) sqlite3_column_text(statement, 19) != NULL)
                    weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)];
                
                if((const char *) sqlite3_column_text(statement, 20) != NULL)
                    booking = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)];
                
                if((const char *) sqlite3_column_text(statement, 21) != NULL)
                    discount = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)];
                
                if((const char *) sqlite3_column_text(statement, 22) != NULL)
                    sku = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)];
                
                if((const char *) sqlite3_column_text(statement, 23) != NULL)
                    size = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)];
                
                if((const char *) sqlite3_column_text(statement, 24) != NULL)
                    weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)];
                
                if((const char *) sqlite3_column_text(statement, 25) != NULL)
                    name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 25)];
                
                if((const char *) sqlite3_column_text(statement, 26) != NULL)
                    caption = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 26)];
                
                if((const char *) sqlite3_column_text(statement, 27) != NULL)
                    url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 27)];
                
                if((const char *) sqlite3_column_text(statement, 28) != NULL)
                    location = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 28)];
                
                if((const char *) sqlite3_column_text(statement, 29) != NULL)
                    email = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 29)];
                
                if((const char *) sqlite3_column_text(statement, 30) != NULL)
                    phone = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 30)];
                
                if((const char *) sqlite3_column_text(statement, 31) != NULL)
                    path_orig = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 31)]
                    ;
                if((const char *) sqlite3_column_text(statement, 32) != NULL)
                    path_proc = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 32)];
                
                if((const char *) sqlite3_column_text(statement, 33) != NULL)
                    path_th = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 33)];
                
                if((const char *) sqlite3_column_text(statement, 34) != NULL)
                    cart_item_stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 34)];
                
                if((const char *) sqlite3_column_text(statement, 35) != NULL)
                    cart_item_item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 35)];
                
                if((const char *) sqlite3_column_text(statement, 36) != NULL)
                    cart_item_quantity = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 36)];
                
                if((const char *) sqlite3_column_text(statement, 37) != NULL)
                    cart_coupon_code = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 37)];
                
                if((const char *) sqlite3_column_text(statement, 38) != NULL)
                    cart_isopen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 38)];
                
                if((const char *) sqlite3_column_text(statement, 39) != NULL)
                    branchinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 39)];
                
                if((const char *) sqlite3_column_text(statement, 40) != NULL)
                    branchinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 40)];
                
                if((const char *) sqlite3_column_text(statement, 41) != NULL)
                    branchstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 41)];
                
                if((const char *) sqlite3_column_text(statement, 42) != NULL)
                    branchitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 42)];
                
                if((const char *) sqlite3_column_text(statement, 43) != NULL)
                    memberinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 43)];
                
                if((const char *) sqlite3_column_text(statement, 44) != NULL)
                    memberinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 44)];
                
                if((const char *) sqlite3_column_text(statement, 45) != NULL)
                    foreign_key = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 45)];
                
                if((const char *) sqlite3_column_text(statement, 46) != NULL)
                    stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 46)];
                
                if((const char *) sqlite3_column_text(statement, 47) != NULL)
                    item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 47)];
                
                NSDictionary *contentValues = @{
                                                DB_COL_ID: _id,
                                                DB_COL_SRV_ID: srv_id,
                                                DB_COL_TYPE: type,
                                                DB_COL_TITLE: title,
                                                DB_COL_SUBTITLE: subtitle,
                                                DB_COL_CONTENT: content,
                                                DB_COL_TIMESTAMP: timestamp,
                                                DB_COL_STOCK: stock,
                                                DB_COL_PRICE: price,
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
                                                DB_COL_WEIGHT: weight,
                                                DB_COL_BOOKING: booking,
                                                DB_COL_DISCOUNT: discount,
                                                DB_COL_SKU: sku,
                                                DB_COL_SIZE: size,
                                                DB_COL_EXTRA_WEIGHT: weight,
                                                DB_COL_NAME: name,
                                                DB_COL_CAPTION: caption,
                                                DB_COL_URL: url,
                                                DB_COL_LOCATION: location,
                                                DB_COL_EMAIL: email,
                                                DB_COL_PHONE: phone,
                                                DB_COL_PATH_ORIG: path_orig,
                                                DB_COL_PATH_PROC: path_proc,
                                                DB_COL_PATH_TH: path_th,
                                                DB_COL_CART_ITEM_STREAM_ID: cart_item_stream_id,
                                                DB_COL_CART_ITEM_ITEM_ID: cart_item_item_id,
                                                DB_COL_CART_ITEM_QUANTITY: cart_item_quantity,
                                                DB_COL_CART_COUPON_CODE: cart_coupon_code,
                                                DB_COL_CART_ISOPEN: cart_isopen,
                                                DB_COL_BRANCHINBOXSTREAM_ID: branchinboxstream_id,
                                                DB_COL_BRANCHINBOXITEM_ID: branchinboxitem_id,
                                                DB_COL_BRANCHSTREAM_ID: branchstream_id,
                                                DB_COL_BRANCHITEM_ID: branchitem_id,
                                                DB_COL_MEMBERINBOXSTREAM_ID: memberinboxstream_id,
                                                DB_COL_MEMBERINBOXITEM_ID: memberinboxitem_id,
                                                DB_COL_FOREIGN_KEY: foreign_key,
                                                DB_COL_STREAM_ID: stream_id,
                                                DB_COL_ITEM_ID: item_id
                                                };
                [selRows addObject:contentValues];
                
                
            }
            sqlite3_reset(statement);
        }
        
        sqlite3_close(database);
        
    }
    
    ////NSLog(@"Returning %d", selRows.count);
    
    return selRows;
}

-(void) cleanPictures;
{
    
    NSError *error;
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    
    for(NSString *file in files) {
        
        
        BOOL flagFound = NO;
        
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            
            
            NSString *querySQL = [NSString stringWithFormat: @"select * from %@", DB_CURR_TABLENAME];
            const char *query_stmt = [querySQL UTF8String];
            
            if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    
                   // //NSLog(@"Columns %d", sqlite3_data_count(statement));
                    NSString *_id = @"", *srv_id = @"", *type = @"", *title = @"", *subtitle = @"", *content = @"", *timestamp = @"", *stock = @"", *price = @"", *extra1 = @"", *extra2 = @"", *extra3 = @"", *extra4 = @"", *extra5 = @"", *extra6 = @"", *extra7 = @"", *extra8 = @"", *extra9 = @"", *extra10 = @"", *weight = @"", *booking = @"", *discount = @"", *sku = @"", *size = @"", *name =@"", *caption = @"", *url = @"", *location = @"", *email = @"", *phone = @"", *path_orig = @"", *path_proc = @"", *path_th = @"", *cart_item_stream_id = @"", *cart_item_item_id = @"", *cart_item_quantity =@"", *cart_coupon_code = @"", *cart_isopen = @"", *branchinboxstream_id = @"", *branchinboxitem_id = @"", *branchstream_id = @"", *branchitem_id = @"", *memberinboxstream_id = @"", *memberinboxitem_id = @"", *foreign_key = @"", *stream_id = @"", *item_id = @"";
                    
                    if((const char *) sqlite3_column_text(statement, 0) != NULL)
                        _id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                    
                    if((const char *) sqlite3_column_text(statement, 1) != NULL)
                        srv_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                    if((const char *) sqlite3_column_text(statement, 2) != NULL)
                        type = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                    
                    if((const char *) sqlite3_column_text(statement, 3) != NULL)
                        title =  [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                    
                    if((const char *) sqlite3_column_text(statement, 4) != NULL)
                        subtitle = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                    
                    if((const char *) sqlite3_column_text(statement, 5) != NULL)
                        content = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                    
                    if((const char *) sqlite3_column_text(statement, 6) != NULL)
                        timestamp = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                    
                    if((const char *) sqlite3_column_text(statement, 7) != NULL)
                        stock = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                    
                    if((const char *) sqlite3_column_text(statement, 8) != NULL)
                        price = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                    
                    if((const char *) sqlite3_column_text(statement, 9) != NULL)
                        extra1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                    
                    if((const char *) sqlite3_column_text(statement, 10) != NULL)
                        extra2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                    
                    if((const char *) sqlite3_column_text(statement, 11) != NULL)
                        extra3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                    
                    if((const char *) sqlite3_column_text(statement, 12) != NULL)
                        extra4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                    
                    if((const char *) sqlite3_column_text(statement, 13) != NULL)
                        extra5 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                    
                    if((const char *) sqlite3_column_text(statement, 14) != NULL)
                        extra6 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                    
                    if((const char *) sqlite3_column_text(statement, 15) != NULL)
                        extra7 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                    
                    if((const char *) sqlite3_column_text(statement, 16) != NULL)
                        extra8 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                    
                    if((const char *) sqlite3_column_text(statement, 17) != NULL)
                        extra9 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                    
                    if((const char *) sqlite3_column_text(statement, 18) != NULL)
                        extra10 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)];
                    
                    if((const char *) sqlite3_column_text(statement, 19) != NULL)
                        weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)];
                    
                    if((const char *) sqlite3_column_text(statement, 20) != NULL)
                        booking = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)];
                    
                    if((const char *) sqlite3_column_text(statement, 21) != NULL)
                        discount = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)];
                    
                    if((const char *) sqlite3_column_text(statement, 22) != NULL)
                        sku = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)];
                    
                    if((const char *) sqlite3_column_text(statement, 23) != NULL)
                        size = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)];
                    
                    if((const char *) sqlite3_column_text(statement, 24) != NULL)
                        weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)];
                    
                    if((const char *) sqlite3_column_text(statement, 25) != NULL)
                        name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 25)];
                    
                    if((const char *) sqlite3_column_text(statement, 26) != NULL)
                        caption = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 26)];
                    
                    if((const char *) sqlite3_column_text(statement, 27) != NULL)
                        url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 27)];
                    
                    if((const char *) sqlite3_column_text(statement, 28) != NULL)
                        location = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 28)];
                    
                    if((const char *) sqlite3_column_text(statement, 29) != NULL)
                        email = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 29)];
                    
                    if((const char *) sqlite3_column_text(statement, 30) != NULL)
                        phone = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 30)];
                    
                    if((const char *) sqlite3_column_text(statement, 31) != NULL)
                        path_orig = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 31)]
                        ;
                    if((const char *) sqlite3_column_text(statement, 32) != NULL)
                        path_proc = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 32)];
                    
                    if((const char *) sqlite3_column_text(statement, 33) != NULL)
                        path_th = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 33)];
                    
                    if((const char *) sqlite3_column_text(statement, 34) != NULL)
                        cart_item_stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 34)];
                    
                    if((const char *) sqlite3_column_text(statement, 35) != NULL)
                        cart_item_item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 35)];
                    
                    if((const char *) sqlite3_column_text(statement, 36) != NULL)
                        cart_item_quantity = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 36)];
                    
                    if((const char *) sqlite3_column_text(statement, 37) != NULL)
                        cart_coupon_code = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 37)];
                    
                    if((const char *) sqlite3_column_text(statement, 38) != NULL)
                        cart_isopen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 38)];
                    
                    if((const char *) sqlite3_column_text(statement, 39) != NULL)
                        branchinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 39)];
                    
                    if((const char *) sqlite3_column_text(statement, 40) != NULL)
                        branchinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 40)];
                    
                    if((const char *) sqlite3_column_text(statement, 41) != NULL)
                        branchstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 41)];
                    
                    if((const char *) sqlite3_column_text(statement, 42) != NULL)
                        branchitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 42)];
                    
                    if((const char *) sqlite3_column_text(statement, 43) != NULL)
                        memberinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 43)];
                    
                    if((const char *) sqlite3_column_text(statement, 44) != NULL)
                        memberinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 44)];
                    
                    if((const char *) sqlite3_column_text(statement, 45) != NULL)
                        foreign_key = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 45)];
                    
                    if((const char *) sqlite3_column_text(statement, 46) != NULL)
                        stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 46)];
                    
                    if((const char *) sqlite3_column_text(statement, 47) != NULL)
                        item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 47)];
                    
                    NSDictionary *contentValues = @{
                                                    DB_COL_ID: _id,
                                                    DB_COL_SRV_ID: srv_id,
                                                    DB_COL_TYPE: type,
                                                    DB_COL_TITLE: title,
                                                    DB_COL_SUBTITLE: subtitle,
                                                    DB_COL_CONTENT: content,
                                                    DB_COL_TIMESTAMP: timestamp,
                                                    DB_COL_STOCK: stock,
                                                    DB_COL_PRICE: price,
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
                                                    DB_COL_WEIGHT: weight,
                                                    DB_COL_BOOKING: booking,
                                                    DB_COL_DISCOUNT: discount,
                                                    DB_COL_SKU: sku,
                                                    DB_COL_SIZE: size,
                                                    DB_COL_EXTRA_WEIGHT: weight,
                                                    DB_COL_NAME: name,
                                                    DB_COL_CAPTION: caption,
                                                    DB_COL_URL: url,
                                                    DB_COL_LOCATION: location,
                                                    DB_COL_EMAIL: email,
                                                    DB_COL_PHONE: phone,
                                                    DB_COL_PATH_ORIG: path_orig,
                                                    DB_COL_PATH_PROC: path_proc,
                                                    DB_COL_PATH_TH: path_th,
                                                    DB_COL_CART_ITEM_STREAM_ID: cart_item_stream_id,
                                                    DB_COL_CART_ITEM_ITEM_ID: cart_item_item_id,
                                                    DB_COL_CART_ITEM_QUANTITY: cart_item_quantity,
                                                    DB_COL_CART_COUPON_CODE: cart_coupon_code,
                                                    DB_COL_CART_ISOPEN: cart_isopen,
                                                    DB_COL_BRANCHINBOXSTREAM_ID: branchinboxstream_id,
                                                    DB_COL_BRANCHINBOXITEM_ID: branchinboxitem_id,
                                                    DB_COL_BRANCHSTREAM_ID: branchstream_id,
                                                    DB_COL_BRANCHITEM_ID: branchitem_id,
                                                    DB_COL_MEMBERINBOXSTREAM_ID: memberinboxstream_id,
                                                    DB_COL_MEMBERINBOXITEM_ID: memberinboxitem_id,
                                                    DB_COL_FOREIGN_KEY: foreign_key,
                                                    DB_COL_STREAM_ID: stream_id,
                                                    DB_COL_ITEM_ID: item_id
                                                    };
                    
                    NSString *imageNameTh = (NSString *) [contentValues objectForKey:DB_COL_PATH_TH];
                    NSString *imageNameProc = (NSString *) [contentValues objectForKey:DB_COL_PATH_PROC];
                    NSString *imageNameOrig = (NSString *) [contentValues objectForKey:DB_COL_PATH_ORIG];
                    
                    
                    if([file isEqualToString:imageNameTh] || [file isEqualToString:imageNameProc] || [file isEqualToString:imageNameOrig])
                    {
                        flagFound = YES;
                    }
                    
                }
                
                
                sqlite3_reset(statement);
                
            }
            sqlite3_close(database);
            
            
        }
        
        if(!flagFound) {
            NSString* imagePath = [documentsPath stringByAppendingPathComponent:file];
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error];
        }
        
        
    }
    
}

-(void) printDB;
{
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select * from %@", DB_CURR_TABLENAME];
        ////NSLog(querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            //NSLog(@"Printing Database");
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSString *_id = @"", *srv_id = @"", *type = @"", *title = @"", *subtitle = @"", *content = @"", *timestamp = @"", *stock = @"", *price = @"", *extra1 = @"", *extra2 = @"", *extra3 = @"", *extra4 = @"", *extra5 = @"", *extra6 = @"", *extra7 = @"", *extra8 = @"", *extra9 = @"", *extra10 = @"", *weight = @"", *booking = @"", *discount = @"", *sku = @"", *size = @"", *name =@"", *caption = @"", *url = @"", *location = @"", *email = @"", *phone = @"", *path_orig = @"", *path_proc = @"", *path_th = @"", *cart_item_stream_id = @"", *cart_item_item_id = @"", *cart_item_quantity =@"", *cart_coupon_code = @"", *cart_isopen = @"", *branchinboxstream_id = @"", *branchinboxitem_id = @"", *branchstream_id = @"", *branchitem_id = @"", *memberinboxstream_id = @"", *memberinboxitem_id = @"", *foreign_key = @"", *stream_id = @"", *item_id = @"";
                
                if((const char *) sqlite3_column_text(statement, 0) != NULL)
                    _id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                
                if((const char *) sqlite3_column_text(statement, 1) != NULL)
                    srv_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                if((const char *) sqlite3_column_text(statement, 2) != NULL)
                    type = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                
                if((const char *) sqlite3_column_text(statement, 3) != NULL)
                    title =  [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                
                if((const char *) sqlite3_column_text(statement, 4) != NULL)
                    subtitle = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                
                if((const char *) sqlite3_column_text(statement, 5) != NULL)
                    content = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                
                if((const char *) sqlite3_column_text(statement, 6) != NULL)
                    timestamp = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)];
                
                if((const char *) sqlite3_column_text(statement, 7) != NULL)
                    stock = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 7)];
                
                if((const char *) sqlite3_column_text(statement, 8) != NULL)
                    price = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 8)];
                
                if((const char *) sqlite3_column_text(statement, 9) != NULL)
                    extra1 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 9)];
                
                if((const char *) sqlite3_column_text(statement, 10) != NULL)
                    extra2 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 10)];
                
                if((const char *) sqlite3_column_text(statement, 11) != NULL)
                    extra3 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 11)];
                
                if((const char *) sqlite3_column_text(statement, 12) != NULL)
                    extra4 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 12)];
                
                if((const char *) sqlite3_column_text(statement, 13) != NULL)
                    extra5 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 13)];
                
                if((const char *) sqlite3_column_text(statement, 14) != NULL)
                    extra6 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 14)];
                
                if((const char *) sqlite3_column_text(statement, 15) != NULL)
                    extra7 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 15)];
                
                if((const char *) sqlite3_column_text(statement, 16) != NULL)
                    extra8 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 16)];
                
                if((const char *) sqlite3_column_text(statement, 17) != NULL)
                    extra9 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 17)];
                
                if((const char *) sqlite3_column_text(statement, 18) != NULL)
                    extra10 = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 18)];
                
                if((const char *) sqlite3_column_text(statement, 19) != NULL)
                    weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 19)];
                
                if((const char *) sqlite3_column_text(statement, 20) != NULL)
                    booking = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 20)];
                
                if((const char *) sqlite3_column_text(statement, 21) != NULL)
                    discount = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 21)];
                
                if((const char *) sqlite3_column_text(statement, 22) != NULL)
                    sku = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 22)];
                
                if((const char *) sqlite3_column_text(statement, 23) != NULL)
                    size = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 23)];
                
                if((const char *) sqlite3_column_text(statement, 24) != NULL)
                    weight = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 24)];
                
                if((const char *) sqlite3_column_text(statement, 25) != NULL)
                    name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 25)];
                
                if((const char *) sqlite3_column_text(statement, 26) != NULL)
                    caption = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 26)];
                
                if((const char *) sqlite3_column_text(statement, 27) != NULL)
                    url = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 27)];
                
                if((const char *) sqlite3_column_text(statement, 28) != NULL)
                    location = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 28)];
                
                if((const char *) sqlite3_column_text(statement, 29) != NULL)
                    email = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 29)];
                
                if((const char *) sqlite3_column_text(statement, 30) != NULL)
                    phone = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 30)];
                
                if((const char *) sqlite3_column_text(statement, 31) != NULL)
                    path_orig = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 31)]
                    ;
                if((const char *) sqlite3_column_text(statement, 32) != NULL)
                    path_proc = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 32)];
                
                if((const char *) sqlite3_column_text(statement, 33) != NULL)
                    path_th = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 33)];
                
                if((const char *) sqlite3_column_text(statement, 34) != NULL)
                    cart_item_stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 34)];
                
                if((const char *) sqlite3_column_text(statement, 35) != NULL)
                    cart_item_item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 35)];
                
                if((const char *) sqlite3_column_text(statement, 36) != NULL)
                    cart_item_quantity = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 36)];
                
                if((const char *) sqlite3_column_text(statement, 37) != NULL)
                    cart_coupon_code = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 37)];
                
                if((const char *) sqlite3_column_text(statement, 38) != NULL)
                    cart_isopen = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 38)];
                
                if((const char *) sqlite3_column_text(statement, 39) != NULL)
                    branchinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 39)];
                
                if((const char *) sqlite3_column_text(statement, 40) != NULL)
                    branchinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 40)];
                
                if((const char *) sqlite3_column_text(statement, 41) != NULL)
                    branchstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 41)];
                
                if((const char *) sqlite3_column_text(statement, 42) != NULL)
                    branchitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 42)];
                
                if((const char *) sqlite3_column_text(statement, 43) != NULL)
                    memberinboxstream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 43)];
                
                if((const char *) sqlite3_column_text(statement, 44) != NULL)
                    memberinboxitem_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 44)];
                
                if((const char *) sqlite3_column_text(statement, 45) != NULL)
                    foreign_key = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 45)];
                
                if((const char *) sqlite3_column_text(statement, 46) != NULL)
                    stream_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 46)];
                
                if((const char *) sqlite3_column_text(statement, 47) != NULL)
                    item_id = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 47)];
                
                
            }
            sqlite3_reset(statement);
        }
        sqlite3_close(database);
    }
    
}

-(void) clearDynamicDataFromDB;
{
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat: @"delete from %@ where \
                               %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'\
                               or %@ = '%@'",
                               DB_CURR_TABLENAME,
                               DB_COL_TYPE, DB_RECORD_TYPE_ITEM,
                               DB_COL_TYPE, DB_RECORD_TYPE_PICTURE,
                               DB_COL_TYPE, DB_RECORD_TYPE_URL,
                               DB_COL_TYPE, DB_RECORD_TYPE_LOCATION,
                               DB_COL_TYPE, DB_RECORD_TYPE_CONTACT,
                               DB_COL_TYPE, DB_RECORD_TYPE_ATTACHMENT,
                               DB_COL_TYPE, DB_RECORD_TYPE_DISCOUNT,
                               DB_COL_TYPE, DB_RECORD_TYPE_COUPON,
                               DB_COL_TYPE, DB_RECORD_TYPE_TAX_1,
                               DB_COL_TYPE, DB_RECORD_TYPE_TAX_2,
                               DB_COL_TYPE, DB_RECORD_TYPE_CART_ITEM,
                               DB_COL_TYPE, DB_RECORD_TYPE_CART,
                               DB_COL_TYPE, DB_RECORD_TYPE_STREAM,
                               DB_COL_TYPE, DB_RECORD_TYPE_DISCOUNT,
                               DB_COL_TYPE, DB_RECORD_TYPE_COUPON,
                               DB_COL_TYPE, DB_STREAM_TYPE_BRANCH,
                               DB_COL_TYPE, DB_RECORD_TYPE_MESSAGESTREAM_PUSH_ALERT,
                               DB_COL_TYPE, DB_STREAM_TYPE_BRANCHINBOX,
                               DB_COL_TYPE, DB_STREAM_TYPE_BRANCHINBOXMESSAGE,
                               DB_COL_TYPE, DB_STREAM_TYPE_MEMBERINBOX,
                               DB_COL_TYPE, DB_STREAM_TYPE_MEMBERINBOXMESSAGE,
                               DB_COL_TYPE, DB_STREAM_TYPE_MEMBERSHIPTYPE,
                               DB_COL_TYPE, DB_STREAM_TYPE_MESSAGE,
                               DB_COL_TYPE, DB_STREAM_TYPE_NOTIFICATION,
                               DB_COL_TYPE, DB_STREAM_TYPE_MYMEMBERSHIP,
                               DB_COL_TYPE, DB_STREAM_TYPE_PRODUCT
                               ];
        //NSLog(@"%@", deleteSQL);
        
        const char *delete_stmt = [deleteSQL UTF8String];
        
        sqlite3_prepare_v2(database, delete_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            //NSLog(@"Delete dynamic from DB");
            
        }
        else {
            
            //NSLog(@"Could not Delete dynamic from DB");
            
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    
}

-(void) clearDB;
{
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat: @"delete from %@", DB_CURR_TABLENAME];
        const char *delete_stmt = [deleteSQL UTF8String];
        
        sqlite3_prepare_v2(database, delete_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            ////////////NSLog(@"Delete from DB");
            
        }
        else {
            
            ////////////NSLog(@"Could not Delete from DB");
            
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
    }
    
}



@end
