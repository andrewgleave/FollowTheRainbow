//
//  RRAppDelegate.m
//  FollowTheRainbow
//
//  Created by Andrew on 22/10/2013.
//  Copyright (c) 2013 Red Robot Studios. All rights reserved.
//

#import "RRAppDelegate.h"
#import "Base64.h"

@implementation RRAppDelegate

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if(url && url.query) {
        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [url.query componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [queryStringDictionary setObject:value forKey:key];
        }
        
        NSString *encodedLatLon = [queryStringDictionary objectForKey:@"t"];
        
        if(encodedLatLon) {
            
            NSArray *latLonArray = [[NSString stringWithBase64EncodedString:encodedLatLon] componentsSeparatedByString:@","];
            
            NSNotification* notification = [NSNotification notificationWithName:@"RRUpdateTargetLocationNotification"
                                                                         object:latLonArray];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }
    
    return NO;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults objectForKey:@"targetLatitude"] || ![defaults objectForKey:@"targetLongitude"]) {
        
        [defaults setObject:[NSNumber numberWithDouble:54.15] forKey:@"targetLatitude"];
        [defaults setObject:[NSNumber numberWithDouble:-4.48] forKey:@"targetLongitude"];
        [defaults synchronize];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
