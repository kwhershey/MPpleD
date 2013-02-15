//
//  mpdFirstViewController.m
//  MPpleD
//
//  Created by Mary Beth McWhinney on 2/11/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdNowPlayingViewController.h"

@interface mpdNowPlayingViewController ()

@end

@implementation mpdNowPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    struct mpd_connection *conn;
    NSString *host = @"192.168.1.2";
    conn = mpd_connection_new([host UTF8String], 6600, 30000);
    if (mpd_connection_get_error(conn) != MPD_ERROR_SUCCESS)
        NSLog(@"Connection error");
    struct mpd_status * status;
    struct mpd_song *song;
    mpd_command_list_begin(conn, true);
    mpd_send_status(conn);
    mpd_send_current_song(conn);
    mpd_command_list_end(conn);
    
    status = mpd_recv_status(conn);
    
    //song = mpd_recv_song(conn);
    
    if (status == NULL)
    {
        self.songInfo.text = @"Connection Error";
    }
    if(mpd_status_get_state(status) == MPD_STATE_PLAY)
    {
        mpd_status_free(status);
        mpd_response_next(conn);
        song = mpd_recv_song(conn);
        self.songInfo.text = [[NSString alloc] initWithUTF8String:mpd_song_get_uri(song)];
    }
    else if(mpd_status_get_state(status) == MPD_STATE_PAUSE)
    {
        self.songInfo.text = @"Paused";
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
