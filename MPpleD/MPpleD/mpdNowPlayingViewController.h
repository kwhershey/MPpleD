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

@interface mpdNowPlayingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *songInfo;


@end
