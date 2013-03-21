//
//  mpdFirstViewController.h
//  MPpleD
//
//  Created by Kyle Hershey on 2/11/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mpd/client.h>
#import <mpd/status.h>
#import "mpdConnectionData.h"

@interface mpdNowPlayingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *artistText;
@property (weak, nonatomic) IBOutlet UILabel *albumText;
@property (weak, nonatomic) IBOutlet UILabel *trackText;
@property (weak, nonatomic) IBOutlet UILabel *curPos;
@property (weak, nonatomic) IBOutlet UILabel *totTime;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prev;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *play;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *next;
@property (weak, nonatomic) IBOutlet UIButton *shuffle;
@property (weak, nonatomic) IBOutlet UISlider *volume;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UIImageView *artViewer;


@property struct mpd_connection *conn;
@property const char* host;
@property int port;

@property BOOL random;
@property BOOL playing;

@property NSTimer *updateTimer;
@property NSTimer *clockTimer;

@property int currentTime;
@property int totalTime;

@property UIImage *artwork;
@property id artworkPath;

-(IBAction) sliderValueChanged:(id)sender;
-(IBAction) positionValueChanged:(UISlider *)sender;
-(IBAction)backToNowPlayingClick:(UIStoryboardSegue *)segue;

@end
