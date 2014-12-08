//
//  PlayBarView.h
//  Parrot
//
//  Created by Marco Argiolas on 08/12/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "ProfileViewController.h"
#import "WallViewController.h"

@interface PlayBarView : UIView
{
    NSTimer *updateTimer;
    IBOutlet UISlider *playSlider;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIButton *respokenButton;
    IBOutlet UIButton *playButton;
    IBOutlet UIButton *leftButton;
    IBOutlet UIButton *rightButton;
    RespokenViewController *respokenVC;
    WallViewController *wallVC;
    ProfileViewController *profileVC;
    SpokeCell *currentPlayingSpokeCell;
    MainViewController *mainVC;
}
@property (strong, nonatomic) MainViewController *mainVC;
@property (strong, nonatomic) SpokeCell *currentPlayingSpokeCell;
@property (strong, nonatomic) RespokenViewController *respokenVC;
@property (strong, nonatomic) WallViewController *wallVC;
@property (strong, nonatomic) ProfileViewController *profileVC;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UISlider *playSlider;

- (IBAction)leftButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)respokenButtonPressed:(id)sender;
- (IBAction)rightButtonPressed:(id)sender;
- (IBAction)progressSliderMoved:(id)sender;
- (void)updateSlider;

@end
