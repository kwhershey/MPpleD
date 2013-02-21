//
//  mpdMusicTableViewController.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/14/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mpdArtistViewController.h"
#import "mpdAlbumViewController.h"

@interface mpdMusicTableViewController : UITableViewController

-(IBAction)backClick:(UIStoryboardSegue *)segue;

@end
