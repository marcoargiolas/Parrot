//
//  MainViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "WallViewController.h"

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UIView *searchContainerView;
    IBOutlet UIView *wallContainerView;
    IBOutlet UIView *profileContainerView;
    IBOutlet UIButton *profileButton;
    IBOutlet UIButton *wallButton;
    IBOutlet UIButton *searchButton;
    IBOutlet UIView *profileBackgroundView;
    IBOutlet UIView *wallBackgroundView;
    IBOutlet UIView *searchBackgroundView;
    
    IBOutlet UIView *buttonsContainerView;
    ProfileViewController *profileVC;
    WallViewController *wallVC;
    SearchViewController *searchVC;
}
@property (strong, nonatomic) IBOutlet UIView *profileBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *wallBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *searchBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *buttonsContainerView;

@property (strong, nonatomic) IBOutlet UIView *profileContainerView;
@property (strong, nonatomic) IBOutlet UIView *wallContainerView;
@property (strong, nonatomic) IBOutlet UIView *searchContainerView;

- (IBAction)profileButtonPressed:(id)sender;
- (IBAction)wallButtonPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;


@end
