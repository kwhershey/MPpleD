//
//  mpdConnectionData.m
//  MPpleD
//
//  Created by Kyle Hershey on 2/16/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdConnectionData.h"

@implementation mpdConnectionData

@synthesize host;
@synthesize port;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static mpdConnectionData *sharedmpdConnectionData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedmpdConnectionData = [[self alloc] init];
    });
    return sharedmpdConnectionData;
}

- (id)init {
    if (self = [super init]) {
        host = @"0.0.0.0";
        port = [[NSNumber alloc] initWithInt:6600];
    }
    
    
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
         host=data[0];
         port=data[1];
     }
    //NSLog(self.host);
    //NSLog(self.port);
    
    
    return self;
}



- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //NSLog(@"Entering Background");
    
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


@end


