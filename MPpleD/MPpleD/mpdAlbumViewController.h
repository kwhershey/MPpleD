//
//  mpdAlbumViewController.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/20/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "albumList.h"

@interface mpdAlbumViewController : UITableViewController

@property (strong, nonatomic) albumList *dataController;

@property (strong, nonatomic) NSString *artistFilter;

-(IBAction)backToAlbumClick:(UIStoryboardSegue *)segue;

@end
