//
//  mpdArtistViewController.h
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/20/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "artistList.h"

@interface mpdArtistViewController : UITableViewController

//Data
@property (strong, nonatomic) artistList *dataController;
@property NSArray *sections;

//Actions
-(IBAction)backToArtistClick:(UIStoryboardSegue *)segue;

@end
