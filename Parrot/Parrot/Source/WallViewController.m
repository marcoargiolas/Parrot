//
//  WallViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "WallViewController.h"
#import "UIImage+Additions.h"
#import "GlobalDefines.h"
#import "Utilities.h"
#import "RecordViewController.h"
#import "MainViewController.h"

#define IMAGE_WIDTH 80

@interface WallViewController ()

@end

@implementation WallViewController

@synthesize wallTableView;
@synthesize currentPlayingTag;
@synthesize player;
@synthesize buttonContainerView;
@synthesize recordButton;
@synthesize playerInPause;
@synthesize mainVC;

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
    
    [UserProfile sharedProfile].cacheSpokesArray = [[NSMutableArray alloc]init];
    maskImage = [UIImage ellipsedMaskFromRect:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_WIDTH) inSize:CGSizeMake(IMAGE_WIDTH, IMAGE_WIDTH)];
    
    currentPlayingTag = -1;
    cellsDict = [[NSMutableDictionary alloc]init];
    [wallTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [buttonContainerView setFrame:CGRectMake(buttonContainerView.frame.origin.x, self.view.frame.size.height - 65 - buttonContainerView.frame.size.height, buttonContainerView.frame.size.width, buttonContainerView.frame.size.height)];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [recordButton addGestureRecognizer:longPress];
    
    [self setupRefreshControl];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController setNavigationBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWallTableView:) name:WALL_SPOKES_ARRIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWallTableView:) name:FIRST_SPOKES_ARRIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadWallSpokes) name:RELOAD_SPOKES_LIST object:nil];
    [mainVC wallButtonPressed:nil];
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    if ([[UserProfile sharedProfile].cacheSpokesArray count] > 0 )
//    {
//        [self loadWallSpokes];
//    }
//}

-(void)loadWallSpokes
{
//    [[UserProfile sharedProfile].cacheSpokesArray removeAllObjects];
    BOOL newSpoke = [[[NSUserDefaults standardUserDefaults]objectForKey:NEW_SPOKE_ADDED] boolValue];
    BOOL updateHeard = [[[NSUserDefaults standardUserDefaults]objectForKey:UPDATE_HEARDS] boolValue];
    BOOL updateLike = [[[NSUserDefaults standardUserDefaults]objectForKey:UPDATE_LIKES] boolValue];
    if([[UserProfile sharedProfile].cacheSpokesArray count] > 0 && (newSpoke || updateLike || updateHeard))
    {
        [UserProfile sharedProfile].cacheSpokesArray = [Utilities orderByDate:[UserProfile sharedProfile].cacheSpokesArray];
        [wallTableView setContentOffset:CGPointZero animated:YES];
        [wallTableView reloadData];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:NEW_SPOKE_ADDED];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:UPDATE_HEARDS];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:UPDATE_LIKES];
    }
    else
    {
        if(!isLoading)
        {
            isLoading = YES;
           [self reloadSpokeArray:nil];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    startRecord = NO;
    [player stop];
    if ([[UserProfile sharedProfile].cacheSpokesArray count] == 0)
    {
        [[UserProfile sharedProfile] saveLocalSpokesCache:[UserProfile sharedProfile].cacheSpokesArray];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadSpokeArray:(NSNotification *)notification
{
//    [self beginRefreshingTableView];
    if ([[UserProfile sharedProfile].cacheSpokesArray count] == 0)
    {
        [[UserProfile sharedProfile] loadFirstResults:5];
    }
    else
        [[UserProfile sharedProfile] loadAllSpokesFromRemote];
}

-(void)reloadWallTableView:(NSNotification*)notification
{
    if ([UserProfile sharedProfile].cacheSpokesArray == nil)
    {
        [UserProfile sharedProfile].cacheSpokesArray = [[NSMutableArray alloc]init];
    }
    if([notification.name isEqualToString:FIRST_SPOKES_ARRIVED])
    {
        [UserProfile sharedProfile].cacheSpokesArray = (NSMutableArray*)[[notification userInfo]objectForKey:FIRST_RESULTS_ARRAY];
    }
    else if([notification.name isEqualToString:WALL_SPOKES_ARRIVED])
    {
        [UserProfile sharedProfile].cacheSpokesArray = (NSMutableArray*)[[notification userInfo]objectForKey:RESULTS_ARRAY];
    }
    
    [[UserProfile sharedProfile] saveLocalSpokesCache:[UserProfile sharedProfile].cacheSpokesArray];
    [UserProfile sharedProfile].cacheSpokesArray = [Utilities orderByDate:[UserProfile sharedProfile].cacheSpokesArray]; 
    [wallTableView reloadData];
    [refreshControl endRefreshing];
    
    isLoading = NO;
}

#pragma mark -
#pragma mark UIRefreshControl
- (void)setupRefreshControl
{
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(reloadSpokeArray:) forControlEvents:UIControlEventValueChanged];
    [refreshControl setBounds:CGRectMake(refreshControl.frame.origin.x, refreshControl.frame.origin.y + 10, refreshControl.frame.size.width, refreshControl.frame.size.height)];
    [refreshControl setTintColor:[UIColor whiteColor]];
    [wallTableView addSubview:refreshControl];
}

- (void) checkRefreshControl
{
    if(refreshControl.isRefreshing)
    {
        [refreshControl endRefreshing];
    }
}

- (void)beginRefreshingTableView
{
    [refreshControl beginRefreshing];
    
    if (wallTableView.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            wallTableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
            
        } completion:^(BOOL finished){
            
        }];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"recordAction"])
    {
        RecordViewController *recordVC = [segue destinationViewController];
        recordVC.startRecord = startRecord;
    }
}

-(void)openUserProfile:(Spoke*)sender
{
    [mainVC openUserProfile:sender];
}

-(void)openRespokenView:(Spoke*)sender
{
    [mainVC openRespokenView:sender];
}

#pragma mark UITableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wallTableView.frame.size.width, 0)];
    
    return footerView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"count %d",(int)[[UserProfile sharedProfile].cacheSpokesArray count]);
    return [[UserProfile sharedProfile].cacheSpokesArray count];
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
    cell.wallVC = self;
    cell.playButton.tag = indexPath.row;
    
    Spoke *spokeObj = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:indexPath.row];

    NSData *img_data = spokeObj.ownerImageData;
    UIImage *userImageLoad = [UIImage imageWithData:img_data];
    if(userImageLoad != nil)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        [cell.spokeImageButton setBackgroundImage:[userImageLoad roundedImageWithSize:CGSizeMake(cell.spokeImageButton.frame.size.width*scale, cell.spokeImageButton.frame.size.height*scale) andMaskImage:maskImage] forState:UIControlStateNormal];
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
    [cell.respokeTotalLabel setText:[NSString stringWithFormat:@"%d",(int)[spokeObj.listOfRespokeID count]]];

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

    [cellsDict setObject:cell forKey:spokeObj.spokeID];
//    int lastRow = (int)[tableView numberOfRowsInSection:indexPath.section]-1;
//    if(lastRow == indexPath.row && indexPath.row == 4)
//    {
//        [userProf loadAllSpokesFromRemote];
//    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Spoke *spokeObj = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:indexPath.row];
    if([spokeObj.ownerID isEqualToString:[[UserProfile sharedProfile] getUserID]])
        return YES;
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [player stop];
        [wallTableView beginUpdates];
        Spoke *spokeToDelete = [[UserProfile sharedProfile].cacheSpokesArray objectAtIndex:indexPath.row];
        NSIndexPath *indexToRefresh;
        if (spokeToDelete.respokeToSpokeID != nil)
        {
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
                            [[UserProfile sharedProfile] updateRespokenList:tempSpoke.spokeID respokeID:spokeID removeRespoken:YES];
                            indexToRefresh = [NSIndexPath indexPathForRow:i inSection:0];
                            break;
                        }
                    }
                }
            }
            if([spokeToDelete.ownerID isEqualToString:[[UserProfile sharedProfile] getUserID]])
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
                                [[UserProfile sharedProfile].spokesArray replaceObjectAtIndex:i withObject:tempSpoke];
                                indexToRefresh = [NSIndexPath indexPathForRow:i inSection:0];
                                break;
                            }
                        }
                    }
                }
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

        [[UserProfile sharedProfile] deleteSpoke:spokeToDelete];
        [[UserProfile sharedProfile].cacheSpokesArray removeObjectAtIndex:indexPath.row];
        if (indexToRefresh != nil)
        {
            [wallTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexToRefresh, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [wallTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [cellsDict removeObjectForKey:spokeToDelete.spokeID];
        [wallTableView endUpdates];
        
        [[UserProfile sharedProfile] saveProfileLocal];
        [[UserProfile sharedProfile] saveLocalSpokesCache:[UserProfile sharedProfile].cacheSpokesArray];
    }
}

-(SpokeCell*)changeCell:(Spoke*)spokeToPlay andIndex:(int)cellIndex
{
    NSLog(@"WALL VIEW CURRENT SPOKE ID %@", spokeToPlay.spokeID);

    SpokeCell *cell = [cellsDict objectForKey:spokeToPlay.spokeID];
    if (cell == nil)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
        cell = (SpokeCell*)[self tableView:wallTableView cellForRowAtIndexPath:indexPath];
    }
    cell.currentSpoke = spokeToPlay;
    cell.playButton.tag = cellIndex;
    cell.wallVC = self;
    cell.currentSpokeIndex = cellIndex;
    self.currentPlayingTag = cellIndex;
   
    [wallTableView reloadData];
    [cell playButtonPressed:cell.playButton];
    return cell;
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        startRecord = YES;
        [self recordButtonPressed:nil];
    }
}

- (IBAction)recordButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"recordAction" sender:nil];
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

-(void)addPlayBarView:(SpokeCell*)cell
{
    mainVC.playBar.playSlider.minimumValue = 0;
    mainVC.playBar.playSlider.maximumValue = self.player.duration;
    
    [mainVC addPlayBarView:self withSpokeCell:cell];
}

-(void)hidePlayBarView:(SpokeCell*)cell
{
    [mainVC hidePlayBarView:self withSpokeCell:cell];
}

@end
