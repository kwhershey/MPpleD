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

@property BOOL randomState;
@property BOOL repeatState;
@property BOOL consumeState;
@property BOOL singleState;
@property BOOL crossState;

@property (strong, nonatomic) IBOutlet UISwitch *shuffle;
@property (strong, nonatomic) IBOutlet UISwitch *repeat;
@property (strong, nonatomic) IBOutlet UISwitch *consume;
@property (strong, nonatomic) IBOutlet UISwitch *singleMode;
@property (strong, nonatomic) IBOutlet UISwitch *crossfade;
-(IBAction)shufflePush:(id)sender;
-(IBAction)repeatPush:(id)sender;
-(IBAction)consumePush:(id)sender;
-(IBAction)singlePush:(id)sender;
-(IBAction)crossfadePush:(id)sender;

@end
