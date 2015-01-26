//
//  PlacesViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 26/01/15.
//  Copyright (c) 2015 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceCell : UITableViewCell
{
    IBOutlet UILabel *placeNameLabel;
}

@property (strong, nonatomic) IBOutlet UILabel *placeNameLabel;

@end

@interface PlacesViewController : UIViewController
{
    NSArray *placesArray;
    NSArray *searchResults;
    NSMutableArray *namePlacesArray;
}

@property (nonatomic, strong) NSArray *placesArray;
@property (strong, nonatomic) IBOutlet UITableView *placesTableView;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end
