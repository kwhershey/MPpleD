//
//  mpdConnectionData.m
//  MPpleD
//
//  Created by Mary Beth McWhinney on 2/16/13.
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
        port = @6600;
    }
    NSLog(@"here");
    
    /*
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
        self.host=data[0];
        self.port=data[1];
        NSLog(@"here");
    }
     */
    
    return self;
}



- (void)dealloc {
    // Should never be called, but just here for clarity really.
}





@end


