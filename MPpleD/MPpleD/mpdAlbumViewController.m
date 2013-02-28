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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.dataController albumCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"albumItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [[cell textLabel] setText:[self.dataController albumAtIndex:indexPath.row]];
    
    UILongPressGestureRecognizer *longPressGesture =
    //[[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)] autorelease];
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowAlbumSongs"]) {
        
        mpdSongTableViewController *songViewController = [segue destinationViewController];
        
        
        if([self.tableView indexPathForSelectedRow].row==0)
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
		//NSLog(@"Long-pressed cell at row %i", indexPath.row);
        [self.dataController addAlbumAtIndexToQueue:indexPath.row artist:self.artistFilter];
	}
}

@end
