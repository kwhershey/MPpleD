//
//  mpdSongTableViewController.h
//  MPpleD
//
//  Created by Mary Beth McWhinney on 2/22/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "songList.h"

@interface mpdSongTableViewController : UITableViewController

@property (strong, nonatomic) songList *dataController;

@property (strong, nonatomic) NSString *artistFilter;

@property (strong, nonatomic) NSString *albumFilter;

@end
