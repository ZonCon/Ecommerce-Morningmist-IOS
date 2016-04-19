//
//  AppDelegate.m
//  Zoncon Ecommerce Morningmist
//
//  Created by Hrushikesh  on 14/04/16.
//  Copyright © 2016 MeGo Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "SyncViewController.h"
#import "globals.h"
#import "DbHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize notifParams = _notifParams;
@synthesize navController = _navController;

static NSMutableData *_responseData;
@synthesize connRegisterToken = _connRegisterToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _notifParams = NULL;
    application.applicationIconBadgeNumber = 0;
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if(_navController.view.window && _navController.isViewLoaded) {
        
        if(IS_OPENED_FROM_DETAIL || IS_OPENED_FROM_RESET || IS_OPENED_FROM_FORGOT || IS_OPENED_FROM_MENU || IS_OPENED_FROM_CART) {
            IS_OPENED_FROM_DETAIL = false;
            IS_OPENED_FROM_MENU = false;
        } else {
            //[self.tabController dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    NSArray *parts = [message componentsSeparatedByString:@":"];
    if(parts.count == 2) {
        
        _notifParams = [NSString stringWithFormat:@"%@::%@", DB_STREAM_TYPE_MESSAGE, parts[0]];
        
    } else {
        
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[[deviceToken description]
                        stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]
                       stringByReplacingOccurrencesOfString:@" "
                       withString:@""];
    NSLog(@"My token is: %@", token);
    
    PUSH_TOKEN = token;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", SERVER, API, API_REGISTER_TOKEN];
    NSString *myRequestString = [NSString stringWithFormat:@"params=[{\"idProject\": \"%@\", \"email\": \"%@\", \"token\": \"%@\", \"tokenValue\": \"%@\"}]", PID,  MY_EMAIL, MY_TOKEN, token];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:20.0];
    [ request setHTTPMethod: @"POST" ];
    [ request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [ request setHTTPBody: myRequestData ];
    _connRegisterToken = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //NSLog(@"Failed to get token, error: %@", error);
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if(connection == _connRegisterToken) {
        
        NSString *data = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
        //NSLog(@"Token Output=%@", data);
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:_responseData //1
                              
                              options:kNilOptions
                              error:&error];
        
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

}

@end
