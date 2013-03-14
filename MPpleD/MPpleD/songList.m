//
//  songList.m
//  MPpleD
//
//  Created by Kyle Hershey on 2/22/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "songList.h"

@interface songList ()

- (void)initializeDefaultDataList;

@end


@implementation songList

- (id)init {
    if (self = [super init]) {        
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

-(id)initWithArtist:(NSString *)artist
{
    if (self = [super init]) {
        [self initializeArtistDataList:artist];
        return self;
    }
    return nil;
}

-(id)initWithAlbum:(NSString *)album
{
    if (self = [super init]) {
        [self initializeAlbumDataList:album];
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
    self.songs = list;
    
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    struct mpd_pair *pair;
    
    if (!mpd_search_db_tags(self.conn, MPD_TAG_TITLE) ||
        !mpd_search_commit(self.conn))
        return;
    
    while ((pair = mpd_recv_pair_tag(self.conn, MPD_TAG_TITLE)) != NULL)
    {
        NSString *songString = [[NSString alloc] initWithUTF8String:pair->value];
        [self.songs addObject:songString];
        mpd_return_pair(self.conn, pair);
    }
    
    mpd_connection_free(self.conn);
    [self.songs sortUsingSelector:@selector(compare:)];
}

-(void)initializeArtistDataList:(NSString *)artist
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    self.songs = list;
    
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
    mpd_search_db_tags(self.conn, MPD_TAG_TITLE);
    mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, cArtist);
    mpd_search_commit(self.conn);
    mpd_command_list_end(self.conn);
    
    struct mpd_pair *pair;
    
    
    while ((pair = mpd_recv_pair_tag(self.conn, MPD_TAG_TITLE)) != NULL)
    {
        NSString *songString = [[NSString alloc] initWithUTF8String:pair->value];
        [self.songs addObject:songString];
        mpd_return_pair(self.conn, pair);
    }
    
    mpd_connection_free(self.conn);
    [self.songs sortUsingSelector:@selector(compare:)];
    
}

-(void)initializeAlbumDataList:(NSString *)album
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    self.songs = list;
    
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    
    const char *cAlbum = [album UTF8String];
    mpd_command_list_begin(self.conn, true);
    //mpd_search_db_tags(self.conn, MPD_TAG_TITLE);
    mpd_search_db_songs(self.conn, true);
    mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ALBUM, cAlbum);

    mpd_search_commit(self.conn);
    mpd_command_list_end(self.conn);
    
    struct mpd_song *song;
    while((song=mpd_recv_song(self.conn))!=NULL)
    {
        [self.songs addObject:[[NSString alloc] initWithUTF8String:mpd_song_get_tag(song, MPD_TAG_TITLE, 0)]];
    }
    
    mpd_connection_free(self.conn);
}


-(NSString*)songAtIndex:(NSUInteger)row
{
    return [self.songs objectAtIndex:row];
}

-(NSUInteger)songCount
{
    return [self.songs count];
}

-(void)addSongAtIndexToQueue:(NSUInteger)row artist:(NSString *)artist album:(NSString *)album;
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
    
    if(artist!=NULL)
        mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, [artist UTF8String]);
    if(album!=NULL)
        mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ALBUM, [album UTF8String]);
    mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_TITLE, [[self songAtIndex:row] UTF8String]);
    mpd_search_commit(self.conn);
    mpd_command_list_end(self.conn);
    mpd_connection_free(self.conn);
}

@end
