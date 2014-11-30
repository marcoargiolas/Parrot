//
//  RespokenViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 09/08/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "RespokenViewController.h"
#import "UIImage+Additions.h"
#import "Utilities.h"
#import "MainViewController.h"
#import "GlobalDefines.h"
#import "RecordViewController.h"

#define IMAGE_WIDTH 80

@implementation RespokenHeaderView

@synthesize totalTimeLabel;
@synthesize currentTimeLabel;
@synthesize respokenDateLabel;
@synthesize respokenSlider;
@synthesize respokenUserButton;
@synthesize respokenUserNameButton;
@synthesize pausePlayButton;
@synthesize playButton;
@synthesize respokenVC;
@synthesize spokePlayer;
@synthesize playContainerView;
@synthesize heardLabel;
@synthesize likeButton;
@synthesize likesLabel;
@synthesize updateTimer;

- (IBAction)respokenUserNameButtonPressed:(id)sender {
}

- (IBAction)respokenUserButtonPressed:(id)sender {
}

- (IBAction)progressSliderMoved:(UISlider*)sender
{
    if(respokenVC != nil)
    {
        [respokenVC.player pause];
        [pausePlayButton setSelected:YES];
        respokenVC.player.currentTime = respokenSlider.value;
        respokenVC.player.currentTime = sender.value;
        currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)respokenVC.player.currentTime / 60, (int)respokenVC.player.currentTime % 60, nil];
        respokenSlider.value = respokenVC.player.currentTime;
    }
}

- (IBAction)likeButtonPressed:(id)sender
{
    if(respokenVC.currentSpoke.listOfThankersID == nil)
    {
        respokenVC.currentSpoke.listOfThankersID = [[NSMutableArray alloc]init];
    }
    
    if (respokenVC != nil)
    {
        if(!likeButton.selected)
        {
            if(![respokenVC.currentSpoke.listOfThankersID containsObject:[respokenVC.userProf getUserID]])
                [respokenVC.currentSpoke.listOfThankersID addObject:[respokenVC.userProf getUserID]];
        }
        else
        {
            if([respokenVC.currentSpoke.listOfThankersID containsObject:[respokenVC.userProf getUserID]])
                [respokenVC.currentSpoke.listOfThankersID removeObject:[respokenVC.userProf getUserID]];
        }
        
        for (int i = 0; i < [respokenVC.userProf.cacheSpokesArray count]; i++)
        {
            Spoke *tempSpoke = [respokenVC.userProf.cacheSpokesArray objectAtIndex:i];
            if ([tempSpoke.spokeID isEqualToString:respokenVC.currentSpoke.spokeID])
            {
                [respokenVC.userProf.cacheSpokesArray replaceObjectAtIndex:i withObject:respokenVC.currentSpoke];
            }
        }

        respokenVC.currentSpoke.totalLikes = (int)[respokenVC.currentSpoke.listOfThankersID count];
        [respokenVC.userProf updateTotalSpokeLike:respokenVC.currentSpoke.spokeID thanksID:[respokenVC.userProf getUserID]addLike:!likeButton.selected totalLikes:(int)[respokenVC.currentSpoke.listOfThankersID count]];
    }
    likeButton.selected = !likeButton.selected;
    
    if([respokenVC.currentSpoke.listOfThankersID count] <= 1)
        likesLabel.text = [NSString stringWithFormat:@"%d like", (int)[respokenVC.currentSpoke.listOfThankersID count]];
    else
        likesLabel.text = [NSString stringWithFormat:@"%d likes", (int)[respokenVC.currentSpoke.listOfThankersID count]];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLikes:) name:@"updateLikes" object:nil];
}

- (IBAction)playButtonPressed:(id)sender
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if(respokenVC.currentPlayingTag != playButton.tag)
    {
        respokenVC.currentPlayingTag = (int)playButton.tag;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RESPOKEN_HEADER_PLAY object:nil];
    if(![respokenVC.player isPlaying] || respokenVC.currentPlayingTag == -1)
    {
        NSError *dataError;
        NSData *soundData = [[NSData alloc] initWithData:respokenVC.currentSpoke.audioData];
        if(dataError != nil)
        {
            NSLog(@"DATA ERROR %@", dataError);
        }
        
        NSError *error;
        AVAudioPlayer *headerPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
        headerPlayer.delegate = self;
        respokenVC.player = headerPlayer;

        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];

        respokenSlider.minimumValue = 0;
        respokenSlider.maximumValue = respokenVC.player.duration;
        
        [respokenVC playSelectedAudio];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changePlayButtonImage) name:PLAYBACK_STOP object:nil];
        [playButton removeFromSuperview];
        
        [playContainerView addSubview:respokenSlider];
        [playContainerView addSubview:currentTimeLabel];
        [playContainerView addSubview:pausePlayButton];
    }
}

- (void)updateSlider
{
    [respokenSlider setFrame:CGRectMake(49, 10, 226, 31)];
    float progress = respokenVC.player.currentTime;
    currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)respokenVC.player.currentTime / 60, (int)respokenVC.player.currentTime % 60, nil];
    [respokenSlider setValue:progress];
}

-(void)changePlayButtonImage
{
    NSLog(@"CHANGE PLAY BUTTON IMAGE");
    [updateTimer invalidate];
    [respokenSlider removeFromSuperview];
    [currentTimeLabel removeFromSuperview];
    [pausePlayButton removeFromSuperview];
    
    [playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
    [playContainerView addSubview:playButton];

    if(![respokenVC.currentSpoke.listOfHeardsID containsObject:[respokenVC.userProf getUserID]])
    {
        [respokenVC.currentSpoke.listOfHeardsID addObject:[respokenVC.userProf getUserID]];
        for (int i = 0; i < [respokenVC.userProf.cacheSpokesArray count]; i++)
        {
            Spoke *tempSpoke = [respokenVC.userProf.cacheSpokesArray objectAtIndex:i];
            if ([tempSpoke.spokeID isEqualToString:respokenVC.currentSpoke.spokeID])
            {
                [respokenVC.userProf.cacheSpokesArray replaceObjectAtIndex:i withObject:respokenVC.currentSpoke];
            }
        }
    }
    
    [respokenVC.userProf updateTotalSpokeHeard:respokenVC.currentSpoke.spokeID heardID:[respokenVC.userProf getUserID]];
    int totalHeard = (int)[respokenVC.currentSpoke.listOfHeardsID count];
    respokenVC.currentSpoke.totalHeards = totalHeard;
    heardLabel.text = [NSString stringWithFormat:@"%d heard", totalHeard];
}

- (IBAction)pausePlayButtonPressed:(id)sender
{
    if(respokenVC != nil)
    {
        if(respokenVC.player.playing)
        {
            [respokenVC.player pause];
            respokenVC.playerInPause = YES;
            [pausePlayButton setSelected:YES];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
        else
        {
            [respokenVC.player play];
            respokenVC.playerInPause = NO;
            [pausePlayButton setSelected:NO];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
    }
}

-(void) stopRespokenPlayer
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

@end

@interface RespokenViewController ()

@end

@implementation RespokenViewController

@synthesize respokenTableView;
@synthesize recordButton;
@synthesize buttonContainerView;
@synthesize mainVC;
@synthesize userProf;
@synthesize player;
@synthesize currentPlayingTag;
@synthesize playerInPause;
@synthesize userId;
@synthesize userImageLoad;
@synthesize userName;
@synthesize currentSpoke;
@synthesize respokenArray;
@synthesize fromRecordView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRespokenArray:) name:RESPOKEN_ARRAY_ARRIVED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopRespokenPlayer) name:CELL_PLAY_STARTED object:nil];
    maskImage = [UIImage ellipsedMaskFromRect:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_WIDTH) inSize:CGSizeMake(IMAGE_WIDTH, IMAGE_WIDTH)];
    
    currentPlayingTag = -1;
    cellsDict = [[NSMutableDictionary alloc]init];
    [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, self.view.frame.size.height - 65 - buttonContainerView.frame.size.height, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
    
    [recordButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [recordButton.layer setShadowOpacity:1.0];
    [recordButton.layer setShadowRadius:3.0];
    [recordButton.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [respokenTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [recordButton addGestureRecognizer:longPress];
    respokenHeader = [[[NSBundle mainBundle] loadNibNamed:@"RespokenHeaderView" owner:self options:nil] objectAtIndex:0];
    
    if(respokenArray == nil)
    {
        respokenArray = [[NSMutableArray alloc]init];
    }
    
    if(refreshControl == nil)
        [self setupRefreshControl];

    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Detail";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    startRecord = NO;
    [player stop];
    BOOL newSpoke = [[[NSUserDefaults standardUserDefaults]objectForKey:NEW_SPOKE_ADDED] boolValue];
    if (newSpoke)
    {
        [mainVC _performReloadCall];
    }
}

-(void)viewWillAppear:(BOOL)animated
{    
    if(userProf == nil)
        userProf = [UserProfile sharedProfile];
    respokenTableView.delegate = nil;
    respokenTableView.dataSource = nil;
    if(!fromRecordView)
        [self requestRespokenArray];
    else
    {
        fromRecordView = NO;
        respokenTableView.delegate = self;
        respokenTableView.dataSource = self;
        [respokenTableView reloadData];
    }
}

-(void)requestRespokenArray
{
    [refreshControl beginRefreshing];
    [userProf respokenForSpokeID:currentSpoke.spokeID];
}

-(void)reloadRespokenArray:(NSNotification*)notification
{
    respokenArray = [Utilities orderByDate:(NSMutableArray*)[[notification userInfo]objectForKey:RESPOKEN_ARRAY]];
    [refreshControl endRefreshing];
    
    respokenTableView.delegate = self;
    respokenTableView.dataSource = self;
    [respokenTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //TABLE VIEW HEADER FIXED
    CGFloat sectionHeaderHeight = respokenHeader.frame.size.height;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    respokenHeader.respokenVC = self;
    [respokenHeader.layer setShadowColor:[UIColor blackColor].CGColor];
    [respokenHeader.layer setShadowOpacity:0.3];
    [respokenHeader.layer setShadowRadius:0];
    [respokenHeader.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [respokenHeader.layer setBorderColor:[UIColor colorWithRed:150.000/255.000 green:150.000/255.000 blue:150.000/255.000 alpha:1.0].CGColor];
    
    [respokenHeader.respokenUserNameButton setTitle:userName forState:UIControlStateNormal];
    
    if(userImageLoad != nil)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        UIImage *userImage = [userImageLoad roundedImageWithSize:CGSizeMake(respokenHeader.respokenUserButton.frame.size.width*scale, respokenHeader.respokenUserButton.frame.size.height*scale) andMaskImage:maskImage];
        [respokenHeader.respokenUserButton setBackgroundImage:userImage forState:UIControlStateNormal];
    }

    respokenHeader.playButton.tag = -1;

    NSError *dataError;
    NSData *soundData = [[NSData alloc] initWithData:currentSpoke.audioData];
    if(dataError != nil)
    {
        NSLog(@"DATA ERROR %@", dataError);
    }
    
    NSError *error;
    AVAudioPlayer *headerPlayer =[[AVAudioPlayer alloc] initWithData: soundData error: &error];
    headerPlayer.delegate = self;
    player = headerPlayer;
    
    respokenHeader.totalTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)headerPlayer.duration / 60, (int)headerPlayer.duration % 60, nil];
    
    [respokenHeader.respokenSlider setThumbImage:[UIImage imageNamed:@"handle_slider.png"] forState:UIControlStateNormal];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMM yyyy"];
    NSString *dateString = [Utilities getDateString:currentSpoke.creationDate WithFormat:format];
    [respokenHeader.respokenDateLabel setText:dateString];
    
    NSString *likeString = @"like";
    NSLog(@"total likes %d for USER %@", (int)[currentSpoke.listOfThankersID count], currentSpoke.ownerName);
    if ([currentSpoke.listOfThankersID containsObject:[userProf getUserID]])
        respokenHeader.likeButton.selected = YES;
    if (currentSpoke.totalLikes > 1)
    {
        likeString = @"likes";
    }
    [respokenHeader.likesLabel setText:[NSString stringWithFormat:@"%d %@", currentSpoke.totalLikes, likeString]];
    [respokenHeader.heardLabel setText:[NSString stringWithFormat:@"%d heard",currentSpoke.totalHeards]];
    
    respokenHeader.respokenSlider.tag = 1;
    
    if(([player isPlaying] || playerInPause) && [[player data]isEqualToData:[respokenHeader.spokePlayer data]])
    {
        [respokenHeader.playContainerView addSubview:respokenHeader.respokenSlider];
        [respokenHeader.playContainerView addSubview:respokenHeader.currentTimeLabel];
        [respokenHeader.playContainerView addSubview:respokenHeader.pausePlayButton];
        [respokenHeader.playButton removeFromSuperview];
        if(playerInPause)
            [respokenHeader.pausePlayButton setSelected:YES];
        else
            [respokenHeader.pausePlayButton setSelected:NO];
    }
    else
    {
        [respokenHeader.respokenSlider removeFromSuperview];
        [respokenHeader.currentTimeLabel removeFromSuperview];
        [respokenHeader.pausePlayButton removeFromSuperview];
        
        if([userProf spokeAlreadyListened:currentSpoke])
            [respokenHeader.playButton setImage:[UIImage imageNamed:@"button_big_replay_enabled.png"] forState:UIControlStateNormal];
        else
            [respokenHeader.playButton setImage:[UIImage imageNamed:@"button_big_play_enabled.png"] forState:UIControlStateNormal];
    }
    
    return respokenHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 166;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, respokenTableView.frame.size.width, 0)];
    
    return footerView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [respokenArray count];
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
        [cell.spokeImageButton setImage:nil forState:UIControlStateNormal];
        [cell.spokeNameButton setTitle:@"" forState:UIControlStateNormal];
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
    cell.respokenVC = self;
    cell.playButton.tag = indexPath.row;
    
    Spoke *spokeObj = [respokenArray objectAtIndex:indexPath.row];
    
    NSData *img_data = spokeObj.ownerImageData;
    UIImage *userImage = [UIImage imageWithData:img_data];
    if(userImage != nil)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        [cell.spokeImageButton setBackgroundImage:[userImage roundedImageWithSize:CGSizeMake(cell.spokeImageButton.frame.size.width*scale, cell.spokeImageButton.frame.size.height*scale) andMaskImage:maskImage] forState:UIControlStateNormal];
    }
    
    [cell.spokeNameButton setTitle:spokeObj.ownerName forState:UIControlStateNormal];
    
//    cell.currentSpoke = spokeObj;
//    cell.currentSpokeIndex = (int)indexPath.row;
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
    
    cell.totalTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)cell.spokePlayer.duration / 60, (int)cell.spokePlayer.duration % 60, nil];
    
    [cell.spokeContainerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [cell.spokeContainerView.layer setShadowOpacity:0.3];
    [cell.spokeContainerView.layer setShadowRadius:0];
    [cell.spokeContainerView.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [cell.spokeContainerView.layer setBorderColor:[UIColor colorWithRed:150.000/255.000 green:150.000/255.000 blue:150.000/255.000 alpha:1.0].CGColor];
    [cell.spokeContainerView.layer setBorderWidth:0.3];
    
    [cell.spokeSlider setThumbImage:[UIImage imageNamed:@"handle_slider.png"] forState:UIControlStateNormal];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMM yyyy"];
    NSString *dateString = [Utilities getDateString:spokeObj.creationDate WithFormat:format];
    [cell.spokeDateLabel setText:dateString];
    
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
    [cellsDict setObject:cell forKey:spokeObj.spokeID];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark UIRefreshControl
- (void)setupRefreshControl
{
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(requestRespokenArray) forControlEvents:UIControlEventValueChanged];
    [refreshControl setBounds:CGRectMake(refreshControl.frame.origin.x, refreshControl.frame.origin.y + 10, refreshControl.frame.size.width, refreshControl.frame.size.height)];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [respokenTableView addSubview:refreshControl];
}

- (void) checkRefreshControl
{
    if(refreshControl.isRefreshing)
    {
        [refreshControl endRefreshing];
    }
}

-(void)reloadWallTableView
{
    respokenArray = [Utilities orderByDate:respokenArray];
    [respokenTableView reloadData];
    [refreshControl endRefreshing];
    if(refreshControl == nil)
        [self setupRefreshControl];
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        startRecord = YES;
        [self recordButtonPressed:nil];
    }
}

-(void)openUserProfile:(Spoke*)sender
{
    [self performSegueWithIdentifier:@"profileAction" sender:nil];
    
//    [mainVC openUserProfile:sender];
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
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
}

-(void) stopRespokenPlayer
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:PLAYBACK_STOP object:nil];
}

-(void)spokeEnded
{
    useSpeaker = YES;
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
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    }
    else
    {
        NSLog(@"SPEAKER");
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    }
    
    if (useSpeaker)
    {
        NSLog(@"WALL VIEW CONTROLLER SPOKE ENDED");
        success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        useSpeaker = NO;
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
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

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"recordAction"])
    {
        RecordViewController *recordVC = [segue destinationViewController];
        recordVC.respokenSpoke = currentSpoke;
        recordVC.respokenVC = self;
        recordVC.startRecord = startRecord;
        startRecord = NO;
    }
}

-(void)changeCell:(Spoke*)spokeToPlay andIndex:(int)cellIndex
{
    SpokeCell *cell = [cellsDict objectForKey:spokeToPlay.spokeID];
    
    cell.currentSpoke = spokeToPlay;
    cell.playButton.tag = cellIndex;
    cell.respokenVC = self;
    cell.currentSpokeIndex = cellIndex;
    self.currentPlayingTag = cellIndex;
    
    [respokenTableView reloadData];
    [cell playButtonPressed:cell.playButton];
}

@end
