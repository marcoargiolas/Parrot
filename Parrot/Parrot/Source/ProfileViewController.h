//
//  ProfileViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import <AVFoundation/AVFoundation.h>
#import "EZAudio.h"
#import "WallViewController.h"
#import "SpokeCell.h"

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate,EZAudioFileDelegate,EZOutputDataSource, AVAudioPlayerDelegate, AVAudioSessionDelegate,AVAudioRecorderDelegate, UIGestureRecognizerDelegate>
{
    UserProfile *userProf;
    NSMutableDictionary *profile;
    IBOutlet UIButton *recordButton;
    IBOutlet UIView *buttonContainerView;
    IBOutlet UIView *contactsContainerView;
    IBOutlet UIView *headerContainerView;
    IBOutlet UILabel *infoLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIImageView *userImageView;
    IBOutlet UITableView *spokesTableView;
    AVAudioPlayer *player;
    UIImage *userImageLoad;
    UIImage *maskImage;
    int currentPlayingTag;
    UIRefreshControl *refreshControl;
    BOOL startRecord;
}

@property (nonatomic, assign) int currentPlayingTag;
@property (strong, nonatomic) UserProfile *userProf;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UITableView *spokesTableView;

- (IBAction)recordButtonPressed:(id)sender;
-(void)playSelectedAudio;

@end
