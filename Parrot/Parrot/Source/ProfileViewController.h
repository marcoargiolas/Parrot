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

@class MainViewController;
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
    BOOL playerInPause;
    BOOL myProfile;
    NSMutableArray *currentSpokenArray;
    IBOutlet UILabel *totalSpokensLabel;
    IBOutlet UILabel *totalSpokensSubLabel;
    IBOutlet UIButton *settingsButton;
    BOOL userProfile;
    NSString *userId;
    NSString *userName;
    MainViewController *mainVC;
    float tableViewOffset_y;
    BOOL isLoading;
}

@property (strong, nonatomic) MainViewController *mainVC;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) UIImage *userImageLoad;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (assign, nonatomic) BOOL userProfile;
@property (nonatomic, strong) NSMutableArray *currentSpokenArray;
@property (nonatomic, assign) BOOL myProfile;
@property (nonatomic, assign) BOOL playerInPause;
@property (nonatomic, assign) int currentPlayingTag;
@property (strong, nonatomic) UserProfile *userProf;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UITableView *spokesTableView;

- (IBAction)recordButtonPressed:(id)sender;
-(void)playSelectedAudio;
- (IBAction)settingsButtonPressed:(id)sender;
-(void)openUserProfile:(Spoke*)sender;
-(void)openRespokenView:(Spoke*)sender;
-(void)reloadMySpokesArray;
-(void)loadSpokesTableView;

@end
