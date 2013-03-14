//
//  mpdConnectionData.h
//  MPpleD
//
//  Created by Kyle Hershey on 2/16/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mpdConnectionData : NSObject{
    NSString *host;
    NSNumber *port;
}

@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSNumber *port;


+ (id)sharedManager;

@end
