//
//  albumList.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/21/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mpd/status.h>
#import <mpd/client.h>
#import "mpdConnectionData.h"

@interface albumList : NSObject

@property struct mpd_connection *conn;
@property const char* host;
@property int port;

@property NSMutableArray *albums;
@property NSString *artist;

-(id)initWithArtist:(NSString *)artist;
-(NSString*)albumAtIndex:(NSUInteger)row;
-(NSUInteger)albumCount;
-(void)addAlbumAtIndexToQueue:(NSUInteger)row artist:(NSString *)artist;

@end
