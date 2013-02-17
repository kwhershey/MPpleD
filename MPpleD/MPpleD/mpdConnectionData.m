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
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end


