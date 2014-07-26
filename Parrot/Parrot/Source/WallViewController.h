//
//  WallViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UserProfile.h"

@interface WallViewController : UIViewController <AVAudioPlayerDelegate, AVAudioSessionDelegate,AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    UserProfile *userProf;
    IBOutlet UITableView *wallTableView;
    AVAudioPlayer *player;
    int currentPlayingTag;
    NSMutableArray *wallSpokesArray;
    UIImage *maskImage;
    UIRefreshControl *refreshControl;
    IBOutlet UIView *buttonContainerView;
    IBOutlet UIButton *recordButton;
    BOOL startRecord;
    BOOL playerInPause;
}

@property (nonatomic, assign) BOOL playerInPause;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) UserProfile *userProf;
@property (nonatomic, assign) int currentPlayingTag;
@property (strong, nonatomic) IBOutlet UITableView *wallTableView;
@property (strong, nonatomic) AVAudioPlayer *player;

-(void)playSelectedAudio;
- (IBAction)recordButtonPressed:(id)sender;

@end
