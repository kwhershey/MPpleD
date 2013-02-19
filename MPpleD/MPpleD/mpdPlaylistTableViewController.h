//
//  mpdPlaylistTableViewController.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/14/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mpdConnectionData.h"

@interface mpdPlaylistTableViewController : UITableViewController

@property struct mpd_connection *conn;
@property const char* host;
@property int port;

@end
