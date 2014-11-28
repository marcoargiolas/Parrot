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

@class MainViewController;
@interface actionBarView : UIView
{
    IBOutlet UIButton *searchButton;
    IBOutlet UIButton *wallButton;
    IBOutlet UIButton *profileButton;
    IBOutlet UIView *searchBackgroundView;
    IBOutlet UIView *profileBackgroundView;
    IBOutlet UIView *wallBackgroundView;
    MainViewController *mainVC;
}

@property (strong, nonatomic) MainViewController *mainVC;
@property (strong, nonatomic) IBOutlet UIButton *wallButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIView *profileBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *wallBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *searchBackgroundView;

- (IBAction)profileButtonPressed:(id)sender;
- (IBAction)wallButtonPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;

@end

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UIView *searchContainerView;
    IBOutlet UIView *wallContainerView;
    IBOutlet UIView *profileContainerView;
    UIButton *profileButton;
    UIButton *wallButton;
    UIButton *searchButton;
    IBOutlet UIView *profileBackgroundView;
    IBOutlet UIView *wallBackgroundView;
    IBOutlet UIView *searchBackgroundView;
    
    IBOutlet UIView *buttonsContainerView;
    ProfileViewController *profileVC;
    WallViewController *wallVC;
    SearchViewController *searchVC;
    actionBarView *actionView;
    Spoke *currentSpokeChoose;
    UserProfile *userProf;
}

@property (strong, nonatomic) actionBarView *actionView;
@property (strong, nonatomic) ProfileViewController *profileVC;
@property (strong, nonatomic) WallViewController *wallVC;
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

-(void)openUserProfile:(Spoke*)sender;
-(void)openRespokenView:(Spoke*)sender;
-(void)_performReloadCall;

@end
