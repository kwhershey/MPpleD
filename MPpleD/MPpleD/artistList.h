//
//  artistList.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/21/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mpd/status.h>
#import <mpd/client.h>
#import "mpdConnectionData.h"

@interface artistList : NSObject

@property struct mpd_connection *conn;
@property const char* host;
@property int port;

@property NSMutableArray *artists;

//-(NSString*)artistAtIndex:(NSUInteger)row;
-(NSString*)artistAtSectionAndIndex:(NSUInteger)section row:(NSUInteger)row;
-(NSUInteger)artistCount;
//-(void)addArtistAtIndexToQueue:(NSUInteger)row;
-(void)addArtistAtSectionAndIndexToQueue:(NSUInteger)section row:(NSUInteger)row;

@end
