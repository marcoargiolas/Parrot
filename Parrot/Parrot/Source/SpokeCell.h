//
//  SpokeCell.h
//  Parrot
//
//  Created by Marco Argiolas on 19/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import <AVFoundation/AVFoundation.h>
#import "ProfileViewController.h"
#import "WallViewController.h"
#import "RespokenViewController.h"

@class ProfileViewController;
@class WallViewController;
@class RespokenViewController;

@interface SpokeCell : UITableViewCell <AVAudioPlayerDelegate, AVAudioSessionDelegate,AVAudioRecorderDelegate>
{
    IBOutlet UIButton *spokeImageButton;
    ProfileViewController *profileVC;
    IBOutlet UIView *spokeContainerView;
    IBOutlet UIButton *playButton;
    IBOutlet UILabel *respokeTotalLabel;
    IBOutlet UIButton *gotoRespokeButton;
    IBOutlet UILabel *spokeDateLabel;
    IBOutlet UILabel *totalTimeLabel;
    IBOutlet UILabel *heardLabel;
    IBOutlet UILabel *currentTimeLabel;
    IBOutlet UILabel *likesLabel;
    IBOutlet UISlider *spokeSlider;
    IBOutlet UIView *playContainerView;
    IBOutlet UIButton *pausePlayButton;
  	NSTimer *updateTimer;
    IBOutlet UIButton *likeButton;
    Spoke *currentSpoke;
    WallViewController *wallVC;
    AVAudioPlayer *spokePlayer;
    int currentSpokeIndex;
    IBOutlet UIButton *spokeNameButton;
    RespokenViewController *respokenVC;
    BOOL useSpeaker;
    BOOL newStart;
}

@property (strong, nonatomic) RespokenViewController *respokenVC;
@property (strong, nonatomic) IBOutlet UIButton *spokeImageButton;
@property (assign, nonatomic) int currentSpokeIndex;
@property (strong, nonatomic) AVAudioPlayer *spokePlayer;
@property (strong, nonatomic) WallViewController *wallVC;
@property (strong, nonatomic) Spoke *currentSpoke;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) IBOutlet UIView *playContainerView;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UISlider *spokeSlider;
@property (strong, nonatomic) IBOutlet UILabel *respokeTotalLabel;
@property (strong, nonatomic) IBOutlet UIButton *gotoRespokeButton;
@property (strong, nonatomic) IBOutlet UIView *spokeContainerView;
@property (strong, nonatomic) IBOutlet UILabel *heardLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *spokeNameButton;
@property (strong, nonatomic) ProfileViewController *profileVC;
@property (strong, nonatomic) IBOutlet UILabel *spokeDateLabel;
@property (strong, nonatomic) IBOutlet UIButton *pausePlayButton;
- (IBAction)spokeNameButtonPressed:(id)sender;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)gotoRespokeButtonPressed:(id)sender;
- (IBAction)likeButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;
- (IBAction)progressSliderMoved:(UISlider*)sender;
- (IBAction)pausePlayButtonPressed:(id)sender;
- (IBAction)spokeImageButtonPressed:(id)sender;
-(void)changePlayButtonImage;

@end
