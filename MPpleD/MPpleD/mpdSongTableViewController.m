//
//  mpdSongTableViewController.m
//  MPpleD
//
//  Created by Kyle Hershey on 2/22/13.
//  Copyright (c) 2013 Kyle Hershey. All rights reserved.
//

#import "mpdSongTableViewController.h"

@interface mpdSongTableViewController ()

@end

@implementation mpdSongTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
        self.dataController = [[songList alloc] init];
}

-(void)setArtistFilter:(NSString *)newArtistFilter
{
    
    if (_artistFilter != newArtistFilter) {
        _artistFilter = newArtistFilter;        
        self.dataController = [[songList alloc] initWithArtist:newArtistFilter];        
    }    
}

-(void)setAlbumFilter:(NSString *)newAlbumFilter
{
    
    if (_albumFilter != newAlbumFilter) {
        _albumFilter = newAlbumFilter;
        self.dataController = [[songList alloc] initWithAlbum:newAlbumFilter];
    }
    //self.sorted = FALSE;
    //NSLog(@"album filtered");
    //[self.tableView reloadData];
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
    //self.sorted = TRUE;
    //self.sections = [NSArray arrayWithObjects:@"#", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //if(self.sorted)
    //    return 27;
    //else
        return 1;
}
/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sections;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.sorted)
    {
        NSArray *sectionArray = [self.dataController.songs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:section]]];
        NSUInteger rowCount = [sectionArray count];
        if(rowCount == 0)
            return nil;
        return [self.sections objectAtIndex:section];
    }
    else return nil;
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    if(self.sorted)
    {
        NSArray *sectionArray = [self.dataController.songs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.sections objectAtIndex:section]]];
        //rowCount = [sectionArray count];
        return [sectionArray count];
    }
     else
     */
    
     return [self.dataController songCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"songItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [[cell textLabel] setText:[self.dataController songAtIndex:indexPath.row]];
    
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        [self.dataController addSongAtIndexToQueue:indexPath.row artist:self.artistFilter album:self.albumFilter];
	}
}

@end
