//
//  mpdPlaybackSettingsViewController.m
//  MPpleD
//
//  Created by KYLE HERSHEY on 3/20/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdPlaybackSettingsViewController.h"

@interface mpdPlaybackSettingsViewController ()

@end

@implementation mpdPlaybackSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateView];
    
    //Start the timers
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector:@selector(updateView) userInfo: nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //Stop timers so doesn't waste resources
    [self.updateTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 * Passive Connection Data loading
 *
 */

-(void)initializeConnection
{
    mpdConnectionData *connection = [mpdConnectionData sharedManager];
    self.host = [connection.host UTF8String];
    self.port = [connection.port intValue];
    self.conn = mpd_connection_new(self.host, self.port, 3000);
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
    
    //get song and status
    struct mpd_status * status;
    mpd_command_list_begin(self.conn, true);
    mpd_send_status(self.conn);
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
        //get all of our status and song info
        if(mpd_status_get_random(status))
        {
            [self.shuffle setOn:TRUE animated:FALSE];
            self.randomState = TRUE;
        }
        else
        {
            [self.shuffle setOn:FALSE animated:FALSE];
            self.randomState = FALSE;
        }
        if(mpd_status_get_repeat(status))
        {
            [self.repeat setOn:TRUE animated:FALSE];
            self.repeatState = TRUE;
        }
        else
        {
            [self.repeat setOn:FALSE animated:FALSE];
            self.repeatState = FALSE;
        }
        if(mpd_status_get_consume(status))
        {
            [self.consume setOn:TRUE animated:FALSE];
            self.consumeState = TRUE;
        }
        else
        {
            [self.consume setOn:FALSE animated:FALSE];
            self.consumeState = FALSE;
        }
        if(mpd_status_get_single(status))
        {
            [self.singleMode setOn:TRUE animated:FALSE];
            self.singleState = TRUE;
        }
        else
        {
            [self.singleMode setOn:FALSE animated:FALSE];
            self.singleState = FALSE;
        }
        if(mpd_status_get_crossfade(status))
        {
            [self.crossfade setOn:TRUE animated:FALSE];
            self.crossState = TRUE;
        }
        else
        {
            [self.crossfade setOn:FALSE animated:FALSE];
            self.crossState = FALSE;
        }
         mpd_status_free(status);
    }
    mpd_connection_free(self.conn);
}


/*
 * User Interactions
 *
 */


-(IBAction)shufflePush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    else
    {
        if(self.randomState)
            mpd_run_random(self.conn, FALSE);
        else
            mpd_run_random(self.conn, TRUE);
    }
    mpd_connection_free(self.conn);
    [self updateView];
}

-(IBAction)repeatPush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    else
    {
        if(self.repeatState)
            mpd_run_repeat(self.conn, FALSE);
        else
            mpd_run_repeat(self.conn, TRUE);
    }
    mpd_connection_free(self.conn);
    [self updateView];
}

-(IBAction)consumePush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    else
    {
        if(self.consumeState)
            mpd_run_consume(self.conn, FALSE);
        else
            mpd_run_consume(self.conn, TRUE);
    }
    mpd_connection_free(self.conn);
    [self updateView];
}

-(IBAction)singlePush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    else
    {
        if(self.singleState)
            mpd_run_single(self.conn, FALSE);
        else
            mpd_run_single(self.conn, TRUE);
    }
    mpd_connection_free(self.conn);
    [self updateView];
}

-(IBAction)crossfadePush:(id)sender
{
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    else
    {
        if(self.crossState)
            mpd_run_crossfade(self.conn, 0);
        else
            mpd_run_crossfade(self.conn, 5);
    }
    mpd_connection_free(self.conn);
    [self updateView];
}


@end
