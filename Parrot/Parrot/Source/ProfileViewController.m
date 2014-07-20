//
//  ProfileViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "ProfileViewController.h"
#import "UIImage+Additions.h"
#import "GlobalDefines.h"
#import <AVFoundation/AVFoundation.h>
#import "Utilities.h"
#import "Spoke.h"

#define IMAGE_WIDTH 80
@interface ProfileViewController ()

@end

//@implementation SpokeCell
//
//@synthesize playButton;
//@synthesize profileVC;
//@synthesize spokeContainerView;
//@synthesize spokeImageView;
//@synthesize spokeNameLabel;
//@synthesize spokeDateLabel;
//@synthesize heardLabel;
//@synthesize respokeTotalLabel;
//@synthesize likesLabel;
//@synthesize gotoRespokeButton;
//@synthesize totalTimeLabel;
//@synthesize currentTimeLabel;
//@synthesize spokeSlider;
//@synthesize playContainerView;
//@synthesize updateTimer;
//@synthesize pausePlayButton;
//@synthesize likeButton;
//@synthesize currentSpoke;
//@synthesize wallVC;
//
//- (IBAction)playButtonPressed:(id)sender
//{
//    if(profileVC.currentPlayingTag != playButton.tag)
//    {
//        profileVC.currentPlayingTag = playButton.tag;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"spokeChanged" object:nil];
//    }
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(spokeChanged) name:@"spokeChanged" object:nil];
//    if(![profileVC.player isPlaying])
//    {
//        NSString *soundFilePath = currentSpoke.spokeID;
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//        
//        NSURL *soundUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.m4a", basePath, soundFilePath]];
//        
//        NSError *dataError;
//        NSData *soundData = [[NSData alloc] initWithContentsOfURL:soundUrl options:NSDataReadingMappedIfSafe error:&dataError];
//        if(dataError != nil)
//        {
//            NSLog(@"DATA ERROR %@", dataError);
//        }
//        
//        NSError *error;
//        AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
//        newPlayer.delegate = self;
//        
//        profileVC.player = newPlayer;
//        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
//        
//        spokeSlider.minimumValue = 0;
//        spokeSlider.maximumValue = profileVC.player.duration;
//        
//        [profileVC playSelectedAudio];
//        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
//        [playButton removeFromSuperview];
//        
//        [playContainerView addSubview:spokeSlider];
//        [playContainerView addSubview:currentTimeLabel];
//        [playContainerView addSubview:pausePlayButton];
//    }
//}
//
//-(void)spokeChanged
//{
//    [self changePlayButtonImage];
//    profileVC.player = nil;
//    [pausePlayButton setSelected:NO];
//}
//
//-(void)changePlayButtonImage
//{
//    [spokeSlider removeFromSuperview];
//    [currentTimeLabel removeFromSuperview];
//    [pausePlayButton removeFromSuperview];
//    [playContainerView addSubview:playButton];
//    [playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
//    [profileVC.userProf updateTotalSpokeHeard:currentSpoke.spokeID heardID:[profileVC.userProf getUserID]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeardLabel) name:@"updateHeards" object:nil];
//}
//
//-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
//{
//    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
//}
//
//-(void)updateHeardLabel
//{
//    int totalHeard = currentSpoke.totalHeards;
//    heardLabel.text = [NSString stringWithFormat:@"%d heard", totalHeard];
//}
//
//
//- (IBAction)gotoRespokeButtonPressed:(id)sender {
//}
//
//- (IBAction)likeButtonPressed:(id)sender
//{
//    if(!likeButton.selected)
//    {
//        likeButton.selected = YES;
//
//        currentSpoke.totalLikes = currentSpoke.totalLikes + 1;
//        [profileVC.userProf updateTotalSpokeLike:currentSpoke.spokeID];
//    }
//    else
//    {
//        likeButton.selected = NO;
//        currentSpoke.totalLikes = currentSpoke.totalLikes - 1;
//        [profileVC.userProf updateTotalSpokeLike:currentSpoke.spokeID];
//    }
//    
//    NSString *likeString = @"like";
//    if (currentSpoke.totalLikes > 1)
//    {
//        likeString = @"likes";
//    }
//
//    likesLabel.text = [NSString stringWithFormat:@"%d %@", currentSpoke.totalLikes, likeString];
//}
//
//- (IBAction)shareButtonPressed:(id)sender {
//}
//
//- (IBAction)progressSliderMoved:(UISlider*)sender
//{
//    [profileVC.player pause];
//    [pausePlayButton setSelected:YES];
//    profileVC.player.currentTime = spokeSlider.value;
//    profileVC.player.currentTime = sender.value;
//    currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
//    spokeSlider.value = profileVC.player.currentTime;
//}
//
//
//- (void)updateSlider
//{
//    if(spokeSlider.tag == playButton.tag)
//    {
//        float progress = profileVC.player.currentTime;
//        currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
//        [spokeSlider setValue:progress];
//    }
//}
//
//- (IBAction)pausePlayButtonPressed:(id)sender
//{
//    if(profileVC.player.playing)
//    {
//        [profileVC.player pause];
//        [pausePlayButton setSelected:YES];
//    }
//    else
//    {
//        [profileVC.player play];
//        [pausePlayButton setSelected:NO];
//    }
//}
//
//@end

@implementation ProfileViewController

@synthesize nameLabel;
@synthesize infoLabel;
@synthesize userImageView;
@synthesize spokesTableView;
@synthesize player;
@synthesize userProf;
@synthesize currentPlayingTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMySpokesArray) name:@"loadUserWall" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMyWallTableView) name:@"userWallSpokesArrived" object:nil];
    [super viewDidLoad];
    userProf = [UserProfile sharedProfile];
    profile = [userProf.currentUser objectForKey:USER_PROFILE];
    
    currentPlayingTag = -1;
    
    maskImage = [UIImage ellipsedMaskFromRect:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_WIDTH) inSize:CGSizeMake(IMAGE_WIDTH, IMAGE_WIDTH)];
    NSData *img_data = [profile objectForKey:USER_IMAGE_DATA];
    userImageLoad = [UIImage imageWithData:img_data];
    if(userImageLoad != nil)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        userImageLoad = [userImageLoad roundedImageWithSize:CGSizeMake(userImageView.frame.size.width*scale, userImageView.frame.size.height*scale) andMaskImage:maskImage];
        [userImageView setImage:userImageLoad];
    }

    [nameLabel setText:[profile objectForKey:USER_FULL_NAME]];
    [infoLabel setText:[profile objectForKey:USER_BIO]];
    
    [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, self.view.frame.size.height - 65 - buttonContainerView.frame.size.height, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
    
    [contactsContainerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [contactsContainerView.layer setShadowOpacity:0.3];
    [contactsContainerView.layer setShadowRadius:0];
    [contactsContainerView.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [contactsContainerView.layer setBorderColor:[UIColor colorWithRed:150.000/255.000 green:150.000/255.000 blue:150.000/255.000 alpha:1.0].CGColor];
    [contactsContainerView.layer setBorderWidth:0.3];
    
    [recordButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [recordButton.layer setShadowOpacity:1.0];
    [recordButton.layer setShadowRadius:3.0];
    [recordButton.layer setShadowOffset:CGSizeMake(0, 1.0)];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(refreshControl == nil)
        [self setupRefreshControl];
    [spokesTableView reloadData];
}

-(void)reloadMySpokesArray
{
    [refreshControl beginRefreshing];
    userProf.spokesArray = [userProf loadSpokesFromRemoteForUser:[userProf getUserID]];
}

-(void)reloadMyWallTableView
{
    userProf.spokesArray = [Utilities orderByDate:userProf.spokesArray];
    [userProf saveProfileLocal];
    [spokesTableView reloadData];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIRefreshControl
- (void)setupRefreshControl
{
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(reloadMySpokesArray) forControlEvents:UIControlEventValueChanged];
    [refreshControl setBounds:CGRectMake(refreshControl.frame.origin.x, refreshControl.frame.origin.y + 10, refreshControl.frame.size.width, refreshControl.frame.size.height)];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [spokesTableView addSubview:refreshControl];
}

- (void) checkRefreshControl
{
    if(refreshControl.isRefreshing)
    {
        [refreshControl endRefreshing];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, spokesTableView.frame.size.width, 0)];
    
    return footerView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count %d",[userProf.spokesArray count]);
    return [userProf.spokesArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)index
{
	return 141;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"spokeCellID";
    SpokeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SpokeCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else
    {
        cell.spokeImageView.image = nil;
        cell.spokeNameLabel.text = @"";
        cell.likesLabel.text = @"";
        cell.likeButton.selected = NO;
        cell.heardLabel.text = @"";
        [cell.playButton setImage:[UIImage imageNamed:@"button_big_play_enabled.png"] forState:UIControlStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.profileVC = self;
    cell.playButton.tag = indexPath.row;
    
    [cell.spokeNameLabel setText:nameLabel.text];

    if(userImageLoad != nil)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        userImageLoad = [userImageLoad roundedImageWithSize:CGSizeMake(cell.spokeImageView.frame.size.width*scale, cell.spokeImageView.frame.size.height*scale) andMaskImage:maskImage];
        [cell.spokeImageView setImage:userImageLoad];
    }
    
    Spoke *spokeObj = [userProf.spokesArray objectAtIndex:indexPath.row];
    cell.currentSpoke = spokeObj;
    NSString *soundFilePath = spokeObj.spokeID;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSURL *soundUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.m4a", basePath, soundFilePath]];
    
    NSError *dataError;
    NSData *soundData = [[NSData alloc] initWithContentsOfURL:soundUrl options:NSDataReadingMappedIfSafe error:&dataError];
    if(dataError != nil)
    {
        NSLog(@"DATA ERROR %@", dataError);
    }
    
    NSError *error;
    AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
    newPlayer.delegate = self;
    
    player = newPlayer;
    
    cell.totalTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)player.duration / 60, (int)player.duration % 60, nil];

    [cell.spokeContainerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [cell.spokeContainerView.layer setShadowOpacity:0.3];
    [cell.spokeContainerView.layer setShadowRadius:0];
    [cell.spokeContainerView.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [cell.spokeContainerView.layer setBorderColor:[UIColor colorWithRed:150.000/255.000 green:150.000/255.000 blue:150.000/255.000 alpha:1.0].CGColor];
    [cell.spokeContainerView.layer setBorderWidth:0.3];
    
    [cell.spokeSlider setThumbImage:[UIImage imageNamed:@"handle_slider.png"] forState:UIControlStateNormal];
    [cell.spokeSlider removeFromSuperview];
    [cell.currentTimeLabel removeFromSuperview];
    [cell.pausePlayButton removeFromSuperview];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMM yyyy"];
    [cell.spokeDateLabel setText:[format stringFromDate:spokeObj.creationDate]];
    
    NSString *likeString = @"like";
    if (spokeObj.totalLikes > 0)
        cell.likeButton.selected = YES;
    if (spokeObj.totalLikes > 1)
    {
        likeString = @"likes";
    }
    [cell.likesLabel setText:[NSString stringWithFormat:@"%d %@", spokeObj.totalLikes, likeString]];
    [cell.heardLabel setText:[NSString stringWithFormat:@"%d heard",spokeObj.totalHeards]];
    
    cell.spokeSlider.tag = indexPath.row;
    
    if([userProf spokeAlreadyListened:spokeObj])
    {
        [cell.playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [spokesTableView beginUpdates];
        [userProf deleteSpoke:[userProf.spokesArray objectAtIndex:indexPath.row]];
        [userProf.spokesArray removeObjectAtIndex:indexPath.row];
        [spokesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [spokesTableView endUpdates];
    }
}

-(void)playSelectedAudio
{
    [player prepareToPlay];
    [player play];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
}

@end
