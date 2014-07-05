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

@class ProfileViewController;
@interface SpokeCell : UITableViewCell
{
    ProfileViewController *profileVC;
    IBOutlet UIView *spokeContainerView;
    IBOutlet UIButton *playButton;
    IBOutlet UIImageView *spokeImageView;
    IBOutlet UILabel *spokeNameLabel;
    IBOutlet UILabel *respokeTotalLabel;
    IBOutlet UIButton *gotoRespokeButton;
    IBOutlet UILabel *spokeDateLabel;
    IBOutlet UILabel *heardLabel;
    IBOutlet UILabel *likesLabel;
}
@property (strong, nonatomic) IBOutlet UILabel *respokeTotalLabel;
@property (strong, nonatomic) IBOutlet UIButton *gotoRespokeButton;
@property (strong, nonatomic) IBOutlet UIView *spokeContainerView;
@property (strong, nonatomic) IBOutlet UILabel *heardLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesLabel;
@property (strong, nonatomic) IBOutlet UILabel *spokeNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *spokeImageView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) ProfileViewController *profileVC;
@property (strong, nonatomic) IBOutlet UILabel *spokeDateLabel;

- (IBAction)playButtonPressed:(id)sender;
- (IBAction)gotoRespokeButtonPressed:(id)sender;
- (IBAction)likeButtonPressed:(id)sender;
- (IBAction)shareButtonPressed:(id)sender;

@end

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITabBarDelegate,EZAudioFileDelegate,EZOutputDataSource, AVAudioPlayerDelegate, AVAudioSessionDelegate,AVAudioRecorderDelegate>
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
}

@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UITableView *spokesTableView;

-(void)playSelectedAudio;

@end
