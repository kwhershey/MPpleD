//
//  mpdFirstViewController.m
//  MPpleD
//
//  Created by Kyle Hershey on 2/11/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdNowPlayingViewController.h"
#import <mpd/client.h>

@interface mpdNowPlayingViewController ()

@end

@implementation mpdNowPlayingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateView];
    self.artwork = [UIImage alloc];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateView];
    
    //Start the timers
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self selector:@selector(updateView) userInfo: nil repeats:YES];
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(artificialClock) userInfo: nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //Stop timers so doesn't waste resources
    [self.updateTimer invalidate];
    [self.clockTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


/*
 * Passive Connection Data loading
 *
 */


//Called to setup self.conn. Used by all database interactions.
//It is best not to reuse the connection for multiple interactions, so setup and
//released each time.
-(void)initializeConnection
{
    mpdConnectionData *connection = [mpdConnectionData sharedManager];
    self.host = [connection.host UTF8String];
    self.port = [connection.port intValue];
    self.conn = mpd_connection_new(self.host, self.port, 3000);
}

//Called every 5 seconds to sync with database info.
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
        //get all of our status and song info
        [self.volume setValue:mpd_status_get_volume(status)];
        self.currentTime = mpd_status_get_elapsed_time(status);
        self.curPos.text = [NSString stringWithFormat:@"%u:%02u", self.currentTime/60,self.currentTime%60];
        self.totalTime = mpd_status_get_total_time(status);
        self.totTime.text = [NSString stringWithFormat:@"%u:%02u",self.totalTime/60,self.totalTime%60 ];
        self.progressSlider.maximumValue = self.totalTime;
        self.progressSlider.value = self.currentTime;

        enum mpd_state playerState;
        //If playing or paused, load all song info.  Else clear all fields.
        if((playerState= mpd_status_get_state(status)) == MPD_STATE_PLAY || mpd_status_get_state(status) == MPD_STATE_PAUSE)
        {
            if(playerState==MPD_STATE_PAUSE)
            {
                self.play.image =[UIImage imageNamed:@"play.png"];
                self.playing = false;
            }
            else
            {
                self.play.image = [UIImage imageNamed:@"pause.png"];
                self.playing = true;
            }
            
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
            //These are all wrapped in try catch statements because if the tag is empty, the
            //function doesn't handle well
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
                NSMutableString *trackString=[[NSMutableString alloc] initWithUTF8String:mpd_song_get_tag(song, MPD_TAG_TRACK, 0)];
                [trackString appendString:@" of "];
                mpd_connection_free(self.conn);
                [trackString appendString:[NSString stringWithFormat:@"%d",[self maxTrackNum:self.artistText.text album:self.albumText.text]]];
                self.trackText.text = trackString;            }
            @catch (NSException *e) {
                self.trackText.text = @"";
            }
            [self getArtwork];
            [self.artViewer setImage:self.artwork];
            
        }
        else
        {
            self.songTitle.text = @"Stopped";
            self.artistText.text = @"";
            self.albumText.text = @"";
            self.trackText.text = @"";
            self.playing=false;
        }
    }
    //mpd_connection_free(self.conn);
}

//uses last.fm web api to fetch the picture.  UpdateView then loads this info into the uiimageview
-(void)getArtwork
{
    UIImage *newArtwork;
    //get the album xml page
    NSMutableString *fetcherString=[[NSMutableString alloc] initWithString:@"http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=892d8cc27ce29468dc4da6d03afc5da9"];
    [fetcherString appendString:@"&artist="];
    [fetcherString appendString:[self.artistText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [fetcherString appendString:@"&album="];
    [fetcherString appendString:[self.albumText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = [[NSError alloc] init];
    NSString *lfmpage = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fetcherString] encoding:NSUTF8StringEncoding error:&error];
    //find the medium image url in the xml
    NSString *search = @"<image size=\"extralarge\">";
    NSString *sub = [lfmpage substringFromIndex:NSMaxRange([lfmpage rangeOfString:search])];
    NSString *endSearch = @"</image>";
    sub=[sub substringToIndex:[sub rangeOfString:endSearch].location];
    
    id path = sub;
    //only fetch the artwork again if the album has changed.  Minimizes data usage.  only fetch each image once.
    if(path!=self.artworkPath)
    {
        self.artworkPath = path;
        NSURL *url = [NSURL URLWithString:path];
        NSData *data = [NSData dataWithContentsOfURL:url];
        newArtwork = [[UIImage alloc] initWithData:data];
        self.artwork = newArtwork;
    }
}

-(NSInteger)maxTrackNum:(NSString*)artist album:(NSString*)album
{
    //NSMutableArray *list = [[NSMutableArray alloc] init];
    NSInteger max=0;
    
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return 0;
    }
    
    const char *cArtist = [artist UTF8String];
    const char *cAlbum = [album UTF8String];
    mpd_command_list_begin(self.conn, true);
    mpd_search_db_tags(self.conn, MPD_TAG_TRACK);
    mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ARTIST, cArtist);
    mpd_search_add_tag_constraint(self.conn, MPD_OPERATOR_DEFAULT, MPD_TAG_ALBUM, cAlbum);
    mpd_search_commit(self.conn);
    mpd_command_list_end(self.conn);
    
    struct mpd_pair *pair;
    
    
    while ((pair = mpd_recv_pair_tag(self.conn, MPD_TAG_TRACK)) != NULL)
    {
        NSString *trackNum = [[NSString alloc] initWithUTF8String:pair->value];
        if([trackNum intValue]>max)
        {
            max=[trackNum intValue];
        }
        mpd_return_pair(self.conn, pair);
    }
    
    
    
    
    mpd_connection_free(self.conn);
    return max;
}


//updates the position bar and timers when playing
-(void)artificialClock
{
    if(self.playing)
    {
        if(self.currentTime<self.totalTime)
        {
            self.currentTime++;
            self.curPos.text = [NSString stringWithFormat:@"%u:%02u", self.currentTime/60,self.currentTime%60];
            self.progressSlider.maximumValue = self.totalTime;
            self.progressSlider.value = self.currentTime;
        }
        else [self updateView];
        
    }
}

/*
 * User Interactions
 *
 */

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
        //if status worked, this is the real action.
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
    mpd_connection_free(self.conn);
    //Rather than update all the info, we just update the view.
    //Doesn't duplicate code, and will only show a state change if call actually worked.
    [self updateView];
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
    mpd_connection_free(self.conn);
    [self updateView];
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
    mpd_connection_free(self.conn);
    [self updateView];
}

//Volume Slider
- (IBAction) sliderValueChanged:(UISlider *)sender {
    [self initializeConnection];
    if (mpd_connection_get_error(self.conn) != MPD_ERROR_SUCCESS)
    {
        NSLog(@"Connection error");
        mpd_connection_free(self.conn);
        [self initializeConnection];
        return;
    }
    mpd_run_set_volume(self.conn, [sender value]);
    mpd_connection_free(self.conn);
}

//Track Time Position
-(IBAction)positionValueChanged:(UISlider *)sender
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
    mpd_send_status(self.conn);
    
    status = mpd_recv_status(self.conn);
    if(status!=NULL)
    {
        mpd_run_seek_pos(self.conn, mpd_status_get_song_pos(status), [sender value]);
        self.currentTime=[sender value];
    }

    mpd_connection_free(self.conn);
}

-(IBAction)artClick:(id)sender
{

    NSMutableString *fetcherString=[[NSMutableString alloc] initWithString:@"http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=892d8cc27ce29468dc4da6d03afc5da9"];
    [fetcherString appendString:@"&artist="];
    [fetcherString appendString:[self.artistText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [fetcherString appendString:@"&album="];
    [fetcherString appendString:[self.albumText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSError *error = [[NSError alloc] init];
    NSString *lfmpage = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fetcherString] encoding:NSUTF8StringEncoding error:&error];
    //find the medium image url in the xml
    NSString *search = @"<url>";
    NSString *sub = [lfmpage substringFromIndex:NSMaxRange([lfmpage rangeOfString:search])];
    NSString *endSearch = @"</url>";
    sub=[sub substringToIndex:[sub rangeOfString:endSearch].location];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: sub]];


}

-(IBAction)artistClick:(id)sender
{
    NSMutableString *fetcherString=[[NSMutableString alloc] initWithString:@"http://ws.audioscrobbler.com/2.0/?method=artist.getinfo"];
    [fetcherString appendString:@"&artist="];
    [fetcherString appendString:[self.artistText.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [fetcherString appendString:@"&api_key=892d8cc27ce29468dc4da6d03afc5da9"];
    NSError *error = [[NSError alloc] init];
    NSString *lfmpage = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fetcherString] encoding:NSUTF8StringEncoding error:&error];
    NSString *search = @"<url>";
    NSString *sub = [lfmpage substringFromIndex:NSMaxRange([lfmpage rangeOfString:search])];
    NSString *endSearch = @"</url>";
    sub=[sub substringToIndex:[sub rangeOfString:endSearch].location];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: sub]];
    
}

    


@end
