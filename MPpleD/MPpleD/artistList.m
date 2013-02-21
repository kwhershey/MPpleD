//
//  artistList.m
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/21/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "artistList.h"
#import "mpdConnectionData.h"

@interface artistList ()

- (void)initializeDefaultDataList;

@end

@implementation artistList

- (id)init {
    
    if (self = [super init]) {
        
        [self initializeDefaultDataList];
        
        return self;
        
    }
    
    return nil;
    
}

-(void)initializeConnection
{
    mpdConnectionData *connection = [mpdConnectionData sharedManager];
    //NSString *host = @"192.168.1.2";
    self.host = [connection.host UTF8String];
    self.port = [connection.port intValue];
    //self.conn = mpd_connection_new([host UTF8String], 6600, 30000);
    self.conn = mpd_connection_new(self.host, self.port, 30000);
}


-(void)initializeDefaultDataList
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    self.artists = list;
    
    //NSLog(@"initializing list");
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    struct mpd_pair *pair;
    
    if (!mpd_search_db_tags(self.conn, MPD_TAG_ARTIST) ||
        !mpd_search_commit(self.conn))
        return;
    
    while ((pair = mpd_recv_pair_tag(self.conn, MPD_TAG_ARTIST)) != NULL)
    {
        //NSLog(@"adding artist");
        NSString *artistString = [[NSString alloc] initWithUTF8String:pair->value];
        //NSLog(artistString);
        [self.artists addObject:artistString];
        //NSLog([[NSNumber alloc] initWithUnsignedInteger:[self artistCount]]);
        mpd_return_pair(self.conn, pair);
    }

    
}

-(NSString*)artistAtIndex:(NSUInteger)row
{
    return [self.artists objectAtIndex:row];
}

-(NSUInteger)artistCount
{
    return [self.artists count];
}

@end
