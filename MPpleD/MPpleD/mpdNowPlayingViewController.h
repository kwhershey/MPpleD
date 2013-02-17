//
//  mpdFirstViewController.h
//  MPpleD
//
//  Created by Mary Beth McWhinney on 2/11/13.
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

@property struct mpd_connection *conn;
@property const char* host;
@property int port;


@end
