//
//  mpdSongTableViewController.h
//  MPpleD
//
//  Created by Kyle Hershey on 2/22/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "songList.h"

@interface mpdSongTableViewController : UITableViewController

@property (strong, nonatomic) songList *dataController;
@property (strong, nonatomic) NSString *artistFilter;
@property (strong, nonatomic) NSString *albumFilter;
@property (assign, nonatomic) bool sorted;
@property NSArray *sections;

@end
