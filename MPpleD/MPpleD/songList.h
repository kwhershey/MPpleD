//
//  songList.h
//  MPpleD
//
//  Created by Kyle Hershey on 2/22/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mpd/status.h>
#import <mpd/client.h>
#import "mpdConnectionData.h"

@interface songList : NSObject

@property struct mpd_connection *conn;
@property const char* host;
@property int port;
@property NSMutableArray *songs;

-(id)initWithArtist:(NSString *)artist;
-(id)initWithAlbum:(NSString *)album;
-(NSString*)songAtIndex:(NSUInteger)row;
-(NSUInteger)songCount;
-(void)addSongAtIndexToQueue:(NSUInteger)row artist:(NSString *)artist album:(NSString *)album;

@end
