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
#import "ParrotNavigationController.h"
#import "MainViewController.h"

#define IMAGE_WIDTH 80
@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize nameLabel;
@synthesize infoLabel;
@synthesize userImageView;
@synthesize spokesTableView;
@synthesize player;
@synthesize currentPlayingTag;
@synthesize myProfile;
@synthesize playerInPause;
@synthesize currentSpokenArray;
@synthesize userProfile;
@synthesize settingsButton;
@synthesize userId;
@synthesize userImageLoad;
@synthesize userName;
@synthesize mainVC;
@synthesize refreshControl;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMyWallTableView:) name:USER_WALL_SPOKEN_ARRIVED object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSpokesTableView) name:RELOAD_SPOKES_LIST object:nil];
    [super viewDidLoad];
    profile = [[UserProfile sharedProfile].currentUser objectForKey:USER_PROFILE];
    
    NSString *name;
    NSString *info;
    if (!userProfile)
    {
        name = [profile objectForKey:USER_FULL_NAME];
        info = [profile objectForKey:USER_BIO];
        userId = [[UserProfile sharedProfile] getUserID];
    }
    else
    {
        name = userName;
        info = @"Info";
        [[UserProfile sharedProfile] loadBioFromRemoteForUser:userId];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInfoLabel:) name:BIO_LOADED object:nil];
        [buttonContainerView removeFromSuperview];
        [settingsButton setImage:nil forState:UIControlStateNormal];
        [settingsButton setTitle:@"Follow" forState:UIControlStateNormal];
        [settingsButton setFrame:CGRectMake(250, 25, 59, 21)];
        [settingsButton setBackgroundColor:[UIColor whiteColor]];
        [settingsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [settingsButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
        settingsButton.layer.cornerRadius = 2;
        [settingsButton.layer setShadowRadius:2.0];
        [settingsButton.layer setBorderWidth:1];

        [headerContainerView setBackgroundColor:[UIColor whiteColor]];
        [nameLabel setTextColor:[UIColor blackColor]];
        [infoLabel setTextColor:[UIColor blackColor]];
        
        
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationItem.title = @"Profile";
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    }
    currentPlayingTag = -1;
    
    maskImage = [UIImage ellipsedMaskFromRect:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_WIDTH) inSize:CGSizeMake(IMAGE_WIDTH, IMAGE_WIDTH)];
    NSData *img_data = [profile objectForKey:USER_IMAGE_DATA];
    if(!userProfile)
        userImageLoad = [UIImage imageWithData:img_data];
    if(userImageLoad != nil)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        [userImageView setImage:[userImageLoad roundedImageWithSize:CGSizeMake(userImageView.frame.size.width*scale, userImageView.frame.size.height*scale) andMaskImage:maskImage]];
    }
    
    [nameLabel setText:name];
    [infoLabel setText:info];
    
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
    
    if(currentSpokenArray == nil)
    {
        currentSpokenArray = [[NSMutableArray alloc]init];
    }
    
    if(refreshControl == nil)
        [self setupRefreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
//    if (!userProfile)
//    {
//        if ([userProf.spokesArray count] > 0)
//        {
//            userProf.spokesArray = [Utilities orderByDate:userProf.spokesArray];
//            currentSpokenArray = [NSMutableArray arrayWithArray:userProf.spokesArray];
//            [spokesTableView reloadData];
//        }
//        else
//        {
//            if (!isLoading)
//            {
//                isLoading = YES;
//                [self reloadMySpokesArray];
//            }
//        }
//    }
//    else
//    {
//        if (!isLoading)
//        {
//            isLoading = YES;
//            [self reloadMySpokesArray];
//        }
//    }
}

-(void)loadSpokesTableView
{
    if (!userProfile)
    {
        if ([[UserProfile sharedProfile].spokesArray count] > 0)
        {
            [UserProfile sharedProfile].spokesArray = [Utilities orderByDate:[UserProfile sharedProfile].spokesArray];
            currentSpokenArray = [NSMutableArray arrayWithArray:[UserProfile sharedProfile].spokesArray];
            [spokesTableView reloadData];
        }
        else
        {
            if (!isLoading)
            {
                isLoading = YES;
                [self reloadMySpokesArray];
            }
        }
        [totalSpokensLabel setText:[NSString stringWithFormat:@"%d", (int)[[UserProfile sharedProfile].spokesArray count]]];
        if ([[UserProfile sharedProfile].spokesArray count] > 1)
        {
            [totalSpokensSubLabel setText:@"Spokens"];
        }
        else
        {
            [totalSpokensSubLabel setText:@"Spoken"];
        }
    }
    else
    {
        if (!isLoading)
        {
            isLoading = YES;
            [self reloadMySpokesArray];
        }
        [totalSpokensLabel setText:[NSString stringWithFormat:@"%d", (int)[[UserProfile sharedProfile].currentUserSpokesArray count]]];
        if ([currentSpokenArray count] > 1)
        {
            [totalSpokensSubLabel setText:@"Spokens"];
        }
        else
        {
            [totalSpokensSubLabel setText:@"Spoken"];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    startRecord = NO;
    [player stop];
}

- (void)beginRefreshingTableView
{
    [refreshControl beginRefreshing];
    
    if (spokesTableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
           spokesTableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
            
        } completion:^(BOOL finished){
            
        }];
    }
}

-(void)reloadMySpokesArray
{
//    [self beginRefreshingTableView];
    isLoading = YES;
    [[UserProfile sharedProfile] loadSpokesFromRemoteForUser:userId];
}

-(void)reloadMyWallTableView:(NSNotification*)notification
{
    NSMutableArray *spokenArrived = (NSMutableArray*)[[notification userInfo]objectForKey:SPOKEN_ARRAY_ARRIVED];
    currentSpokenArray = [Utilities orderByDate:spokenArrived];
    [[UserProfile sharedProfile] saveProfileLocal];
    [spokesTableView reloadData];
    [refreshControl endRefreshing];
    [totalSpokensLabel setText:[NSString stringWithFormat:@"%d", (int)[currentSpokenArray count]]];
    if ([currentSpokenArray count] > 1)
    {
        [totalSpokensSubLabel setText:@"Spokens"];
    }
    else
    {
        [totalSpokensSubLabel setText:@"Spoken"];
    }
    isLoading = NO;
}

-(void)reloadInfoLabel:(NSNotification*)notification
{
    NSString *infoString = (NSString*)[[notification userInfo]objectForKey:BIO_ARRIVED];
    [infoLabel setText:infoString];
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
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat offsetY = scrollView.contentOffset.y;
//    [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, self.view.frame.size.height - 80, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
//    if (!isLoading)
//    {
//        if (offsetY > tableViewOffset_y)
//        {
//            NSLog(@"NASCONDI");
//            [UIView animateWithDuration:0.4 animations:^{
//                [mainVC.navigationController.navigationBar setFrame:CGRectMake(0, -60, mainVC.navigationController.navigationBar.frame.size.width, mainVC.navigationController.navigationBar.frame.size.height)];
//                [mainVC.view setFrame:CGRectMake(mainVC.view.frame.origin.x, 20, mainVC.view.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
//                [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, self.view.frame.size.height - 80, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
//            } completion:^(BOOL finished) {
//            }];
//        }
//        else
//        {
////            [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - 88, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
//
//            NSLog(@"MOSTRA");
//            [UIView animateWithDuration:0.4 animations:^{
//                [mainVC.navigationController.navigationBar setFrame:CGRectMake(0, 20, mainVC.navigationController.navigationBar.frame.size.width, mainVC.navigationController.navigationBar.frame.size.height)];
//                [mainVC.view setFrame:CGRectMake(mainVC.view.frame.origin.x, 64, mainVC.view.frame.size.width, mainVC.view.frame.size.height)];
//                [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, self.view.frame.size.height + 64, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
//
//            }];
//        }
//        tableViewOffset_y = offsetY;
//        if(tableViewOffset_y <= 0)
//        {
//            [mainVC.navigationController.navigationBar setFrame:CGRectMake(0, 20, mainVC.navigationController.navigationBar.frame.size.width, mainVC.navigationController.navigationBar.frame.size.height)];
//            [mainVC.view setFrame:CGRectMake(mainVC.view.frame.origin.x, 64, mainVC.view.frame.size.width, mainVC.view.frame.size.height)];
////            [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, [UIScreen mainScreen].bounds.size.height + 88, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
//        }
//    }
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    UICollectionViewCell *lastCell = [[self.mainCollectionView visibleCells] lastObject];
//    NSIndexPath *indexPath = [self.mainCollectionView indexPathForCell:lastCell];
//    
//    int threshold = (([currentObjectsArray count] - 3) > 0) ? ([currentObjectsArray count] - 3) : 0;
//    
//    if (indexPath.row > 18 || indexPath.row >= threshold) {
//        footerCollectionView.topButton.hidden = NO;
//    }
//    else {
//        footerCollectionView.topButton.hidden = YES;
//    }
//}

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
        [cell.spokeImageButton setBackgroundImage:nil forState:UIControlStateNormal];
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
    cell.profileVC = self;
    cell.playButton.tag = indexPath.row;
    
    [cell.spokeNameButton setTitle:nameLabel.text forState:UIControlStateNormal];

    if(userImageLoad != nil)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        [cell.spokeImageButton setBackgroundImage:[userImageLoad roundedImageWithSize:CGSizeMake(cell.spokeImageButton.frame.size.width*scale, cell.spokeImageButton.frame.size.height*scale) andMaskImage:maskImage] forState:UIControlStateNormal];
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
    cell.currentSpokeIndex = (int)indexPath.row;
    
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
    if ([spokeObj.listOfThankersID containsObject:[[UserProfile sharedProfile] getUserID]])
        cell.likeButton.selected = YES;
    if (spokeObj.totalLikes > 1)
    {
        likeString = @"likes";
    }
    [cell.likesLabel setText:[NSString stringWithFormat:@"%d %@", spokeObj.totalLikes, likeString]];
    [cell.heardLabel setText:[NSString stringWithFormat:@"%d heard",spokeObj.totalHeards]];
    
    cell.spokeSlider.tag = indexPath.row;
    [cell.respokeTotalLabel setText:[NSString stringWithFormat:@"%d",(int)[spokeObj.listOfRespokeID count]]];
    
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
        
        if([[UserProfile sharedProfile] spokeAlreadyListened:spokeObj])
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
    if([userId isEqualToString:[[UserProfile sharedProfile] getUserID]])
        return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [spokesTableView beginUpdates];
        Spoke *spokeToDelete = [currentSpokenArray objectAtIndex:indexPath.row];
        
        NSIndexPath *indexToRefresh;
        if (spokeToDelete.respokeToSpokeID != nil)
        {
            for(int i = 0; i < [[UserProfile sharedProfile].spokesArray count]; i++)
            {
                Spoke *tempSpoke = [[UserProfile sharedProfile].spokesArray objectAtIndex:i];
                if ([tempSpoke.spokeID isEqualToString:spokeToDelete.respokeToSpokeID])
                {
                    for (int j = 0; j < [tempSpoke.listOfRespokeID count]; j++)
                    {
                        NSString *spokeID = [tempSpoke.listOfRespokeID objectAtIndex:j];
                        if ([spokeID isEqualToString:spokeToDelete.spokeID])
                        {
                            [tempSpoke.listOfRespokeID removeObjectAtIndex:j];
                            [[UserProfile sharedProfile] updateRespokenList:tempSpoke.spokeID respokeID:spokeID removeRespoken:YES];
                            [[UserProfile sharedProfile].spokesArray replaceObjectAtIndex:i withObject:tempSpoke];
                            indexToRefresh = [NSIndexPath indexPathForRow:i inSection:0];
                            break;
                        }
                    }
                }
            }
            for(int i = 0; i < [[UserProfile sharedProfile].cacheSpokesArray count]; i++)
            {
                Spoke *tempSpoke = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:i];
                if ([tempSpoke.spokeID isEqualToString:spokeToDelete.respokeToSpokeID])
                {
                    for (int j = 0; j < [tempSpoke.listOfRespokeID count]; j++)
                    {
                        NSString *spokeID = [tempSpoke.listOfRespokeID objectAtIndex:j];
                        if ([spokeID isEqualToString:spokeToDelete.spokeID])
                        {
                            [tempSpoke.listOfRespokeID removeObjectAtIndex:j];
                            [[UserProfile sharedProfile].cacheSpokesArray replaceObjectAtIndex:i withObject:tempSpoke];
                            break;
                        }
                    }
                }
            }
        }
        
        for(int i = 0; i < [[UserProfile sharedProfile].cacheSpokesArray count]; i++)
        {
            Spoke *tempSpoke = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:i];
            if ([tempSpoke.spokeID isEqualToString:spokeToDelete.spokeID])
            {
                [[UserProfile sharedProfile].cacheSpokesArray removeObjectAtIndex:i];
                break;
            }
        }

        for(int i = 0; i < [[UserProfile sharedProfile].spokesArray count]; i++)
        {
            Spoke *tempSpoke = [[UserProfile sharedProfile].spokesArray objectAtIndex:i];
            if ([tempSpoke.spokeID isEqualToString:spokeToDelete.spokeID])
            {
                [[UserProfile sharedProfile].spokesArray removeObjectAtIndex:i];
                break;
            }
        }
        
        [[UserProfile sharedProfile] deleteSpoke:[currentSpokenArray objectAtIndex:indexPath.row]];
        [currentSpokenArray removeObjectAtIndex:indexPath.row];
        if (indexToRefresh != nil)
        {
            [spokesTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexToRefresh, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [spokesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [spokesTableView endUpdates];
        
        [totalSpokensLabel setText:[NSString stringWithFormat:@"%d", (int)[[UserProfile sharedProfile].spokesArray count]]];
        if ([currentSpokenArray count] > 1)
        {
            [totalSpokensSubLabel setText:@"Spokens"];
        }
        else
        {
            [totalSpokensSubLabel setText:@"Spoken"];
        }

        [[UserProfile sharedProfile] saveProfileLocal];
        [[UserProfile sharedProfile] saveLocalSpokesCache:[UserProfile sharedProfile].cacheSpokesArray];
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

- (IBAction)settingsButtonPressed:(id)sender {
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
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

-(void)openUserProfile:(Spoke*)sender
{
    [mainVC openUserProfile:sender];
}

-(void)openRespokenView:(Spoke*)sender
{
    [mainVC openRespokenView:sender];
}

@end
