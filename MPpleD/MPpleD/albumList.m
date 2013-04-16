//
//  albumList.m
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/21/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "albumList.h"
#import "mpdConnectionData.h"

@interface albumList ()

- (void)initializeDefaultDataList;

@end

@implementation albumList

//
//Initializers
//

- (id)init {
    
    if (self = [super init]) {
        
        [self initializeDefaultDataList];
        
        return self;
        
    }
    
    return nil;
    
}

-(id)initWithArtist:(NSString *)initArtist
{
    if (self = [super init]) {
        
        [self initializeArtistDataList:initArtist];
        self.artist = [[NSString alloc] initWithString:initArtist];
        
        
        return self;
        
    }
    
    return nil;
}


-(void)initializeConnection
{
    mpdConnectionData *connection = [mpdConnectionData sharedManager];
    self.host = [connection.host UTF8String];
    self.port = [connection.port intValue];
    self.conn = mpd_connection_new(self.host, self.port, 30000);
}


-(void)initializeDefaultDataList
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    self.albums = list;
    
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    struct mpd_pair *pair;
    
    if (!mpd_search_db_tags(self.conn, MPD_TAG_ALBUM) ||
        !mpd_search_commit(self.conn))
        return;
    
    while ((pair = mpd_recv_pair_tag(self.conn, MPD_TAG_ALBUM)) != NULL)
    {
        NSString *albumString = [[NSString alloc] initWithUTF8String:pair->value];
        [self.albums addObject:albumString];
        mpd_return_pair(self.conn, pair);
    }
    
    mpd_connection_free(self.conn);
    [self.albums sortUsingSelector:@selector(compare:)];
}

-(void)initializeArtistDataList:(NSString *)artist
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    self.albums = list;
    
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    
    const char *cArtist = [artist UTF8String];
    mpd_command_list_begin(self.conn, true);
    mpd_search_db_tags(self.conn, MPD_TAG_ALBUM);
    mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, cArtist);
    mpd_search_commit(self.conn);
    mpd_command_list_end(self.conn);
    
    struct mpd_pair *pair;
    
    
    while ((pair = mpd_recv_pair_tag(self.conn, MPD_TAG_ALBUM)) != NULL)
    {
        NSString *albumString = [[NSString alloc] initWithUTF8String:pair->value];
        [self.albums addObject:albumString];
        mpd_return_pair(self.conn, pair);
    }
    
    mpd_connection_free(self.conn);
    [self.albums sortUsingSelector:@selector(compare:)];
    [self.albums insertObject:@"All" atIndex:0];
}

//
//Data retreival
//

/*
-(NSString*)albumAtIndex:(NSUInteger)row
{
    return [self.albums objectAtIndex:row];
}
 */

-(NSString*)albumAtSectionAndIndex:(NSUInteger)section row:(NSUInteger)row
{
    NSMutableArray *sectionArray = [[NSMutableArray alloc] initWithArray:[self sectionArray:section]];
    if(section==2) //takes care of "all"
    {
        [sectionArray removeObjectAtIndex:0];
    }
    return [sectionArray objectAtIndex:row];
}

-(NSUInteger)albumCount
{
    return [self.albums count];
}


-(void)addAlbumAtSectionAndIndexToQueue:(NSUInteger)section row:(NSUInteger)row artist:(NSString *)artist
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    
    mpd_command_list_begin(self.conn, true);
    
    mpd_search_add_db_songs(self.conn, TRUE);
    
    if(artist!=NULL) //we are in an artists list, so add that constraint
    {
        mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, [artist UTF8String]);
    }
    if(![[self albumAtSectionAndIndex:section row:row] isEqualToString:@"All"])  //only add album if it is not all
    {
        mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ALBUM, [[self albumAtSectionAndIndex:section row:row] UTF8String]);
    }
    
    mpd_search_commit(self.conn);
    mpd_command_list_end(self.conn);
    mpd_connection_free(self.conn);
    
}

-(NSArray*)sectionArray:(NSUInteger)section
{
    NSArray *sections = [NSArray arrayWithObjects:@"all",@"#", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
    NSPredicate *evaluator= [NSPredicate alloc];
    if(section==0)
    {
        return [NSArray arrayWithObject:@"All"];
    }
    if(section==1)
    {
        NSMutableArray *albums = [[NSMutableArray alloc] initWithArray:self.albums];
        char first;
        for (int i = [albums count]-1; i>=0; i--)
        {
            first=[((NSString*)[albums objectAtIndex:i]) UTF8String][0];
            if(isalpha(first))
            {
                [albums removeObjectAtIndex:i];
            }
            
        }
        return albums;
    }
    else
    {
        evaluator = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [sections objectAtIndex:section]];
        return [[NSMutableArray alloc] initWithArray:[self.albums filteredArrayUsingPredicate:evaluator]];
    }
}

@end

