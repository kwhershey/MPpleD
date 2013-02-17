//
//  mpdServerSettingsViewController.m
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/14/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdServerSettingsViewController.h"

@interface mpdServerSettingsViewController ()

@end

@implementation mpdServerSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


static int handle_error(struct mpd_connection *c)
{
	assert(mpd_connection_get_error(c) != MPD_ERROR_SUCCESS);
    
	fprintf(stderr, "%s\n", mpd_connection_get_error_message(c));
	mpd_connection_free(c);
	return EXIT_FAILURE;
}

-(IBAction)connectPush:(id)sender
{
    struct mpd_connection *conn;
    mpdConnectionData *globalConnection = [mpdConnectionData sharedManager];
    globalConnection.host = self.ipTextField.text;
    globalConnection.port = [[NSNumber alloc] initWithInt:[self.portTextField.text intValue]];
    self.host = [self.ipTextField.text UTF8String];
    self.port = [self.portTextField.text intValue];
    //NSLog(@"Assigned to c-string");
    
    
	conn = mpd_connection_new(self.host, self.port, 30000);
    
	if (mpd_connection_get_error(conn) != MPD_ERROR_SUCCESS)
        self.connectionLabel.text = @"Connection Failed";
    else
    {
        self.connectionLabel.text = @"Connected to MPD!";
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Some_Notification_Name"
                                                            //object:(__bridge id)(conn)];
    }
}




- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
 //   if (theTextField == self.textField) {
        
        
    [theTextField resignFirstResponder];
        
        
        
 //   }
    
    return YES;
    
}



@end