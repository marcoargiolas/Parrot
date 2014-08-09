//
//  RespokenViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 09/08/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpokeCell.h"

@class RespokenViewController;
@interface RespokenHeaderView : UIView
{
    IBOutlet UIButton *pausePlayButton;
    IBOutlet UILabel *respokenDateLabel;
    IBOutlet UIButton *respokenUserNameButton;
    IBOutlet UIButton *respokenUserButton;
    IBOutlet UILabel *currentTimeLabel;
    IBOutlet UILabel *totalTimeLabel;
    IBOutlet UISlider *respokenSlider;
    IBOutlet UIButton *playButton;
    RespokenViewController *respokenVC;
    AVAudioPlayer *spokePlayer;
    IBOutlet UIButton *likeButton;
    IBOutlet UILabel *heardLabel;
    IBOutlet UILabel *likesLabel;
    IBOutlet UIView *playContainerView;
  	NSTimer *updateTimer;
}

@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) IBOutlet UIView *playContainerView;
@property (strong, nonatomic) AVAudioPlayer *spokePlayer;
@property (strong, nonatomic) IBOutlet UILabel *heardLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) RespokenViewController *respokenVC;
@property (strong, nonatomic) IBOutlet UISlider *respokenSlider;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *pausePlayButton;
@property (strong, nonatomic) IBOutlet UIButton *respokenUserNameButton;
@property (strong, nonatomic) IBOutlet UILabel *respokenDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *respokenUserButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

- (IBAction)respokenUserNameButtonPressed:(id)sender;
- (IBAction)playButtonPressed:(id)sender;
- (IBAction)progressSliderMoved:(id)sender;
- (IBAction)likeButtonPressed:(id)sender;

- (IBAction)respokenUserButtonPressed:(id)sender;
- (IBAction)pausePlayButtonPressed:(id)sender;

@end

@interface RespokenViewController : UIViewController <AVAudioPlayerDelegate, AVAudioSessionDelegate,AVAudioRecorderDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UITableView *respokenTableView;
    UserProfile *userProf;
    AVAudioPlayer *player;
    int currentPlayingTag;
    NSMutableArray *respokenArray;
    UIImage *maskImage;
    UIRefreshControl *refreshControl;
    IBOutlet UIView *buttonContainerView;
    IBOutlet UIButton *recordButton;
    BOOL startRecord;
    BOOL playerInPause;
    MainViewController *mainVC;
    RespokenHeaderView *respokenHeader;
    NSString *userName;
    NSString *userId;
    UIImage *userImageLoad;
    Spoke *currentSpoke;
}

@property (strong, nonatomic) Spoke *currentSpoke;
@property (strong, nonatomic) IBOutlet UITableView *respokenTableView;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (nonatomic, strong) MainViewController *mainVC;
@property (nonatomic, strong) NSMutableArray *wallSpokesArray;
@property (nonatomic, assign) BOOL playerInPause;
@property (strong, nonatomic) UserProfile *userProf;
@property (nonatomic, assign) int currentPlayingTag;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) UIImage *userImageLoad;

-(void)playSelectedAudio;
-(void)openUserProfile:(Spoke*)sender;
- (IBAction)recordButtonPressed:(id)sender;

@end
