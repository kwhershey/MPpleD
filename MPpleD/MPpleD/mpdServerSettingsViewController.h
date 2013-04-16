//
//  mpdServerSettingsViewController.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/14/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <mpd/client.h>
#import "mpdConnectionData.h"

@interface mpdServerSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;
@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;
@property (strong, nonatomic) IBOutlet UIButton *updateDB;

//Server Settings
@property const char *host;
@property int port;

static int handle_error(struct mpd_connection *c);

@end
