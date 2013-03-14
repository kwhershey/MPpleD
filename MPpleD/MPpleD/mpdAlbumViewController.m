//
//  mpdAlbumViewController.m
//  MPpleD
//
//  Created by KYLE HERSHEY on 2/20/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdAlbumViewController.h"
#import "mpdSongTableViewController.h"

@interface mpdAlbumViewController ()

@end

@implementation mpdAlbumViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    if(self.artistFilter)
    {
        self.dataController = [[albumList alloc] initWithArtist:self.artistFilter];
    }
    else{
        self.dataController = [[albumList alloc] init];
    }
}

-(void)setArtistFilter:(NSString *)newArtistFilter
{
    
    if (_artistFilter != newArtistFilter) {
        
        _artistFilter = newArtistFilter;
        
        self.dataController = [[albumList alloc] initWithArtist:newArtistFilter];
        
    }
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataController albumCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"albumItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [[cell textLabel] setText:[self.dataController albumAtIndex:indexPath.row]];
    
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowAlbumSongs"]) {
        
        mpdSongTableViewController *songViewController = [segue destinationViewController];
        
        
        if(self.artistFilter && [self.tableView indexPathForSelectedRow].row==0)
        {
            songViewController.artistFilter = self.artistFilter;
            songViewController.navigationItem.title = self.artistFilter;
        }
        else{
            songViewController.albumFilter = [self.dataController albumAtIndex:[self.tableView indexPathForSelectedRow].row];
            songViewController.navigationItem.title = [self.dataController albumAtIndex:[self.tableView indexPathForSelectedRow].row];
        }
    }
    
}

-(IBAction)backToAlbumClick:(UIStoryboardSegue *)segue
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
	// only when gesture was recognized, not when ended
	if (gesture.state == UIGestureRecognizerStateBegan)
	{
		// get affected cell
		UITableViewCell *cell = (UITableViewCell *)[gesture view];
        
		// get indexPath of cell
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
		// do something with this action
        [self.dataController addAlbumAtIndexToQueue:indexPath.row artist:self.artistFilter];
	}
}

@end
