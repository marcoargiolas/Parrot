//
//  PlacesViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 26/01/15.
//  Copyright (c) 2015 Marco Argiolas. All rights reserved.
//

#import "PlacesViewController.h"
#import "GlobalDefines.h"

@implementation PlaceCell

@synthesize placeNameLabel;

@end

@interface PlacesViewController ()

@end

@implementation PlacesViewController

@synthesize placesArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    placesArray = [[NSUserDefaults standardUserDefaults]objectForKey:CURRENT_PLACES_SET];
    
    self.navigationController.view.frame = CGRectMake(0.0, 100.0, 320.0, 426.0);
    self.navigationController.navigationBar.frame = CGRectMake(0.0, 100.0, 320.0, 44.0);
}

- (void)didReceiveMemoryWarning {
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [searchResults count];
    return [placesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"placeCellID";
    
    PlaceCell *cell = (PlaceCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[PlaceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    else
    {
        cell.placeNameLabel.text = @"";
    }
    
    if (cell.placeNameLabel == nil)
    {
        cell.placeNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 11, 271, 21)];
        [cell addSubview:cell.placeNameLabel];
    }

    NSMutableDictionary *tempDict;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        tempDict = [searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        tempDict = [placesArray objectAtIndex:indexPath.row];
    }

    cell.placeNameLabel.text = [tempDict objectForKey:@"name"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [[NSUserDefaults standardUserDefaults]setObject:[searchResults objectAtIndex:indexPath.row] forKey:PLACE_CHOOSE];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]setObject:[placesArray objectAtIndex:indexPath.row] forKey:PLACE_CHOOSE];
    }
    
    [self doneButtonPressed:nil];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButtonPressed:(id)sender {
}

#pragma mark Search Delegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    searchResults = [placesArray filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end
