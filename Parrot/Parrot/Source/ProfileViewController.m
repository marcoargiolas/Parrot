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
#import "RecordViewController.h"

#define IMAGE_WIDTH 80
@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize nameLabel;
@synthesize infoLabel;
@synthesize userImageView;
@synthesize spokesTableView;
@synthesize player;
@synthesize userProf;
@synthesize currentPlayingTag;
@synthesize myProfile;
@synthesize playerInPause;
@synthesize currentSpokenArray;

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
    
    [spokesTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [recordButton addGestureRecognizer:longPress];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(currentSpokenArray == nil)
    {
        currentSpokenArray = [[NSMutableArray alloc]init];
    }
    if (myProfile)
    {
        currentSpokenArray = userProf.spokesArray;
    }

    if(refreshControl == nil)
        [self setupRefreshControl];
    if([currentSpokenArray count] > 0)
        currentSpokenArray = [Utilities orderByDate:currentSpokenArray];
    [spokesTableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    startRecord = NO;
    [player stop];
}

-(void)reloadMySpokesArray
{
    [refreshControl beginRefreshing];
    currentSpokenArray = [userProf loadSpokesFromRemoteForUser:[userProf getUserID]];
}

-(void)reloadMyWallTableView
{
    currentSpokenArray = [Utilities orderByDate:currentSpokenArray];
    [userProf saveProfileLocal];
    [spokesTableView reloadData];
    [refreshControl endRefreshing];
    [totalSpokensLabel setText:[NSString stringWithFormat:@"%d", [currentSpokenArray count]]];
    if ([currentSpokenArray count] > 1)
    {
        [totalSpokensSubLabel setText:@"Spokens"];
    }
    else
    {
        [totalSpokensSubLabel setText:@"Spoken"];
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"recordAction"])
    {
        RecordViewController *recordVC = [segue destinationViewController];
        recordVC.startRecord = startRecord;
        startRecord = NO;
    }
}

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
    return [currentSpokenArray count];
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
        cell.spokeDateLabel.text = @"";
        cell.spokePlayer = nil;
        [cell.playContainerView addSubview:cell.playButton];
        [cell.spokeSlider removeFromSuperview];
        [cell.currentTimeLabel removeFromSuperview];
        [cell.pausePlayButton removeFromSuperview];
        [cell.pausePlayButton setSelected:NO];
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
    
    Spoke *spokeObj = [currentSpokenArray objectAtIndex:indexPath.row];
    cell.currentSpoke = spokeObj;

    NSError *dataError;
    NSData *soundData = [[NSData alloc] initWithData:spokeObj.audioData];
    if(dataError != nil)
    {
        NSLog(@"DATA ERROR %@", dataError);
    }
    
    NSError *error;
    AVAudioPlayer *newPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
    newPlayer.delegate = self;

    cell.spokePlayer = newPlayer;
    cell.currentSpokeIndex = indexPath.row;
    
    cell.totalTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)cell.spokePlayer.duration / 60, (int)cell.spokePlayer.duration % 60, nil];

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
    [cell.spokeDateLabel setText:[Utilities getDateString:spokeObj.creationDate WithFormat:format]];
    
    NSString *likeString = @"like";
    if (spokeObj.totalLikes > 0 && [spokeObj.listOfThankersID containsObject:[userProf getUserID]])
        cell.likeButton.selected = YES;
    if (spokeObj.totalLikes > 1)
    {
        likeString = @"likes";
    }
    [cell.likesLabel setText:[NSString stringWithFormat:@"%d %@", spokeObj.totalLikes, likeString]];
    [cell.heardLabel setText:[NSString stringWithFormat:@"%d heard",spokeObj.totalHeards]];
    
    cell.spokeSlider.tag = indexPath.row;
    
    if(([player isPlaying] || playerInPause) && [[player data]isEqualToData:[cell.spokePlayer data]])
    {
        [cell.playContainerView addSubview:cell.spokeSlider];
        [cell.playContainerView addSubview:cell.currentTimeLabel];
        [cell.playContainerView addSubview:cell.pausePlayButton];
        [cell.playButton removeFromSuperview];
        if(playerInPause)
            [cell.pausePlayButton setSelected:YES];
        else
            [cell.pausePlayButton setSelected:NO];
    }
    else
    {
        [cell.spokeSlider removeFromSuperview];
        [cell.currentTimeLabel removeFromSuperview];
        [cell.pausePlayButton removeFromSuperview];
        
        if([userProf spokeAlreadyListened:spokeObj])
            [cell.playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
        else
            [cell.playButton setImage:[UIImage imageNamed:@"button_big_play_enabled.png"] forState:UIControlStateNormal];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
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
        [userProf deleteSpoke:[currentSpokenArray objectAtIndex:indexPath.row]];
        [currentSpokenArray removeObjectAtIndex:indexPath.row];
        [spokesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [spokesTableView endUpdates];
    }
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture
{
    startRecord = YES;
    [self recordButtonPressed:nil];
}

- (IBAction)recordButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"recordAction" sender:nil];
}

-(void)playSelectedAudio
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [player prepareToPlay];
    [player play];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (!success)
        NSLog(@"AVAudioSession error setting category:%@",error);

    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"ORECCHIO");
        //get your app's audioSession singleton object
        
        //set the audioSession override
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                             error:&error];
    }
    else
    {
        NSLog(@"SPEAKER");
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    }

    if (!success)
        NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success)
        NSLog(@"AVAudioSession error activating: %@",error);
    else
        NSLog(@"audioSession active");
}

@end
