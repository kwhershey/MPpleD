//
//  mpdFirstViewController.m
//  MPpleD
//
//  Created by Mary Beth McWhinney on 2/11/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdNowPlayingViewController.h"
#import "mpdServerSettingsViewController.h"

@interface mpdNowPlayingViewController ()

@end

@implementation mpdNowPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateView];
     
    [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector:@selector(updateView) userInfo: nil repeats:YES];
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


-(void)updateView
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    struct mpd_status * status;
    struct mpd_song *song;
    mpd_command_list_begin(self.conn, true);
    mpd_send_status(self.conn);
    mpd_send_current_song(self.conn);
    mpd_command_list_end(self.conn);
    

    status = mpd_recv_status(self.conn);
    
    if (status == NULL)
    {
        NSLog(@"Connection error status");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    else{
        if(mpd_status_get_state(status) == MPD_STATE_PLAY || mpd_status_get_state(status) == MPD_STATE_PAUSE)
        {
            
            if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
            {
                NSLog(@"Connection error free");
                mpd_connection_free(self.conn);
                [self initializeConnection];
                return;
            }
            mpd_status_free(status);
            mpd_response_next(self.conn);
            song = mpd_recv_song(self.conn);
            @try {
                self.songTitle.text = [[NSString alloc] initWithUTF8String:mpd_song_get_tag(song, MPD_TAG_TITLE, 0)];
            }
            @catch (NSException *e) {
            
                self.songTitle.text = @"";
            }
            @try {
                self.artistText.text = [[NSString alloc] initWithUTF8String:mpd_song_get_tag(song, MPD_TAG_ARTIST, 0)];
            }
            @catch (NSException *e) {
            
                self.artistText.text = @"";
            }
            @try {
                self.albumText.text = [[NSString alloc] initWithUTF8String:mpd_song_get_tag(song, MPD_TAG_ALBUM, 0)];
            }
            @catch (NSException *e) {
            
                self.albumText.text = @"";
            }
            @try {
                self.trackText.text = [[NSString alloc] initWithUTF8String:mpd_song_get_tag(song, MPD_TAG_TRACK, 0)];
            }
            @catch (NSException *e) {
                self.trackText.text = @"";
            }
        
        }
        else
        {
            self.songTitle.text = @"Stopped";
            self.artistText.text = @"";
            self.albumText.text = @"";
            self.trackText.text = @"";
        }
    }
    mpd_connection_free(self.conn);
    
    
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)playPausePush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    struct mpd_status * status;
    mpd_command_list_begin(self.conn, true);
    mpd_send_status(self.conn);
    mpd_command_list_end(self.conn);
    
    
    status = mpd_recv_status(self.conn);
    if (status == NULL)
    {
        NSLog(@"Connection error status");
        mpd_connection_free(self.conn);
        return;
    }
    else
    {
        if(mpd_status_get_state(status) == MPD_STATE_PLAY || mpd_status_get_state(status) == MPD_STATE_PAUSE)
        {

            mpd_response_finish(self.conn);
            mpd_status_free(status);
            mpd_run_toggle_pause(self.conn);
        }
        else
        {
            mpd_response_finish(self.conn);
            mpd_status_free(status);
            mpd_run_play(self.conn);
        }
    }
}

-(IBAction)nextPush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    mpd_run_next(self.conn);
    
}

-(IBAction)prevPush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    mpd_run_previous(self.conn);
    
}

-(IBAction)getPlaylist:(id)sender
{
    /*
    [self initializeConnection];
    mpd_send_list_queue_meta(self.conn);
    struct mpd_pair *newPair = mpd_recv_pair(self.conn);
    NSString *name = [[NSString alloc] initWithUTF8String:newPair->name];
    NSString *value = [[NSString alloc] initWithUTF8String:newPair->value];
    NSLog(name);
    NSLog(value);
    newPair = mpd_recv_pair(self.conn);
    name = [[NSString alloc] initWithUTF8String:newPair->name];
    value = [[NSString alloc] initWithUTF8String:newPair->value];
    NSLog(name);
    NSLog(value);
*/
    
    [self initializeConnection];
    struct mpd_song *nextSong = malloc(sizeof(struct mpd_song));
    NSString *title;
    unsigned int pos=0;
    while((nextSong=mpd_run_get_queue_song_pos(self.conn, pos)))
    {
        title=[[NSString alloc] initWithUTF8String:mpd_song_get_tag(nextSong, MPD_TAG_TITLE, 0)];
        NSLog(title);
        pos++;
    }

  }

@end
