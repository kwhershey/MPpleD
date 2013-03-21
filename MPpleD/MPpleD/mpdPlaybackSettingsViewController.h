//
//  mpdPlaybackSettingsViewController.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 3/20/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mpd/client.h>
#import <mpd/status.h>
#import "mpdConnectionData.h"

@interface mpdPlaybackSettingsViewController : UITableViewController

@property struct mpd_connection *conn;
@property const char* host;
@property int port;

@property NSTimer *updateTimer;
-(IBAction)shufflePush:(id)sender;
@property BOOL randomState;

@property (strong, nonatomic) IBOutlet UISwitch *shuffle;
@property (strong, nonatomic) IBOutlet UISwitch *random;
@property (strong, nonatomic) IBOutlet UISwitch *consume;

@end
