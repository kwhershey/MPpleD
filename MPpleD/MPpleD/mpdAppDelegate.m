//
//  mpdAppDelegate.m
//  MPpleD
//
//  Created by Mary Beth McWhinney on 2/11/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdAppDelegate.h"

@implementation mpdAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

/*
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
 */

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/*
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
 */

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Entering Background");
    
    mpdConnectionData *globalConnection = [mpdConnectionData sharedManager];
    //NSLog(@"here");
    NSArray *data = [[NSArray alloc] initWithObjects:globalConnection.host, globalConnection.port, nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullFileName = [NSString stringWithFormat:@"%@/data.plist", docDir];
    [NSKeyedArchiver archiveRootObject:data toFile:fullFileName];
    //NSLog(@"here2");
    
    //globalConnection.host = self.ipTextField.text;
    //globalConnection.port = [[NSNumber alloc] initWithInt:[self.portTextField.text intValue]];

    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    NSLog(@"reload called");
    
    mpdConnectionData *globalConnection = [mpdConnectionData sharedManager];
    
    UIApplication *myApp = [UIApplication sharedApplication];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:myApp];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"data.plist"];
    if ([fileManager fileExistsAtPath:filePath] == YES)
    {
        NSMutableArray *data = [[NSMutableArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:filePath]];
        globalConnection.host=data[0];
        globalConnection.port=data[1];
        NSLog(@"here");
    }
}

@end
