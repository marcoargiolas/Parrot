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

@implementation SpokeCell

@synthesize playButton;
@synthesize profileVC;
@synthesize spokeContainerView;
@synthesize spokeImageView;
@synthesize spokeNameLabel;
@synthesize spokeDateLabel;
@synthesize heardLabel;
@synthesize respokeTotalLabel;
@synthesize likesLabel;
@synthesize gotoRespokeButton;
@synthesize totalTimeLabel;
@synthesize currentTimeLabel;
@synthesize spokeSlider;
@synthesize playContainerView;
@synthesize updateTimer;
@synthesize pausePlayButton;
@synthesize likeButton;

- (IBAction)playButtonPressed:(id)sender
{
    if(![profileVC.player isPlaying])
    {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        
        spokeSlider.minimumValue = 0;
        spokeSlider.maximumValue = profileVC.player.duration;
        
        [profileVC playSelectedAudio];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
        [playButton removeFromSuperview];
        
        [playContainerView addSubview:spokeSlider];
        [playContainerView addSubview:currentTimeLabel];
        [playContainerView addSubview:pausePlayButton];
    }
}

-(void)changePlayButtonImage
{
    [spokeSlider removeFromSuperview];
    [currentTimeLabel removeFromSuperview];
    [pausePlayButton removeFromSuperview];
    [playContainerView addSubview:playButton];
    [playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
}


- (IBAction)gotoRespokeButtonPressed:(id)sender {
}

- (IBAction)likeButtonPressed:(id)sender
{
    if(!likeButton.selected)
    {
        Spoke *currentSpoke = [profileVC.userProf.spokesArray objectAtIndex:playButton.tag];
        currentSpoke.totalLikes = currentSpoke.totalLikes + 1;
        [profileVC.userProf updateTotalSpokeLike:currentSpoke.spokeID];
    }
}

- (IBAction)shareButtonPressed:(id)sender {
}

- (IBAction)progressSliderMoved:(UISlider*)sender
{
    [profileVC.player pause];
    [pausePlayButton setSelected:YES];
    profileVC.player.currentTime = spokeSlider.value;
	profileVC.player.currentTime = sender.value;
    currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
	spokeSlider.value = profileVC.player.currentTime;
}


- (void)updateSlider
{
    float progress = profileVC.player.currentTime;
    currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)profileVC.player.currentTime / 60, (int)profileVC.player.currentTime % 60, nil];
    [spokeSlider setValue:progress];
}

- (IBAction)pausePlayButtonPressed:(id)sender
{
    if(profileVC.player.playing)
    {
        [profileVC.player pause];
        [pausePlayButton setSelected:YES];
    }
    else
    {
        [profileVC.player play];
        [pausePlayButton setSelected:NO];
    }
}

@end

@implementation ProfileViewController

@synthesize nameLabel;
@synthesize infoLabel;
@synthesize userImageView;
@synthesize spokesTableView;
@synthesize player;
@synthesize userProf;

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
    [super viewDidLoad];
    userProf = [UserProfile sharedProfile];
    profile = [userProf.currentUser objectForKey:USER_PROFILE];
    
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
    NSLog(@"PROFILE %@", userProf.spokesArray);
    if([userProf.spokesArray count] > 0)
    {
//        player = [[AVAudioPlayer alloc]init];
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [[AVAudioSession sharedInstance] setActive: YES error:nil];
    }
    [spokesTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [cell.likesLabel setText:[NSString stringWithFormat:@"%d",spokeObj.totalLikes]];
    [cell.heardLabel setText:[NSString stringWithFormat:@"%d",spokeObj.totalHeards]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
