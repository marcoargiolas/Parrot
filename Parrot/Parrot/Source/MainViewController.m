//
//  MainViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "MainViewController.h"
#import "ParrotNavigationController.h"
#import "AppDelegate.h"
#import "Utilities.h"

@implementation actionBarView

@synthesize profileButton;
@synthesize profileBackgroundView;
@synthesize wallButton;
@synthesize wallBackgroundView;
@synthesize searchButton;
@synthesize searchBackgroundView;
@synthesize mainVC;

- (IBAction)profileButtonPressed:(id)sender
{
    [mainVC profileButtonPressed:sender];
}

- (IBAction)wallButtonPressed:(id)sender
{
    [mainVC wallButtonPressed:sender];
}

- (IBAction)searchButtonPressed:(id)sender
{
    [mainVC searchButtonPressed:sender];
}

@end

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize profileContainerView;
@synthesize wallContainerView;
@synthesize searchContainerView;
@synthesize profileBackgroundView;
@synthesize wallBackgroundView;
@synthesize searchBackgroundView;
@synthesize actionView;
@synthesize buttonsContainerView;
@synthesize profileVC;
@synthesize wallVC;
@synthesize playBar;
@synthesize mainView;

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
    [profileContainerView setFrame:CGRectMake(profileContainerView.frame.origin.x, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    [wallContainerView setFrame:CGRectMake(wallContainerView.frame.origin.x, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    [searchContainerView setFrame:CGRectMake(searchContainerView.frame.origin.x, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    [buttonsContainerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [buttonsContainerView.layer setShadowOpacity:0.3];
    [buttonsContainerView.layer setShadowRadius:0];
    [buttonsContainerView.layer setShadowOffset:CGSizeMake(0, 1.0)];
    [buttonsContainerView.layer setBorderColor:[UIColor colorWithRed:150.000/255.000 green:150.000/255.000 blue:150.000/255.000 alpha:1.0].CGColor];
    [buttonsContainerView.layer setBorderWidth:0.3];

    actionView = [[[NSBundle mainBundle] loadNibNamed:@"actionBar" owner:self options:nil] objectAtIndex:0];
    actionView.mainVC = self;
    profileVC.mainVC = self;
    wallVC.mainVC = self;
    
    [userProf loadLocalSpokesCache];
    
    playBar = [[[NSBundle mainBundle]loadNibNamed:@"PlayBarView" owner:self options:nil] objectAtIndex:0];
    [playBar setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20, playBar.frame.size.width, playBar.frame.size.height)];
    [playBar.playSlider setThumbImage:[UIImage imageNamed:@"handle_slider.png"] forState:UIControlStateNormal];
    playBar.mainVC = self;
    
    [self.view addSubview:playBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar addSubview:actionView];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"background_navbar@2x.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
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

//-(void) swipeRight:(UISwipeGestureRecognizer *) recognizer
//{
//    if(actionView.profileButton.selected)
//        return;
//    if(actionView.wallButton.selected)
//    {
//        [self profileButtonPressed:nil];
//        return;
//    }
//    if(actionView.searchButton.selected)
//    {
//        [self wallButtonPressed:nil];
//        return;
//    }
//}
//
//-(void) swipeLeft:(UISwipeGestureRecognizer *) recognizer
//{
//    if(actionView.profileButton.selected)
//    {
//        [self wallButtonPressed:nil];
//        return;
//    }
//    if(actionView.wallButton.selected)
//    {
//        [self searchButtonPressed:nil];
//        return;
//    }
//    if(actionView.searchButton.selected)
//        return;
//}

- (IBAction)profileButtonPressed:(id)sender
{
    if (actionView.profileButton.selected)
    {
        return;
    }

    [UIView animateWithDuration:.25
                     animations:^{
                         [profileContainerView setFrame:CGRectMake(0, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, profileContainerView.frame.size.height)];
                         [wallContainerView setFrame:CGRectMake(self.view.frame.size.width, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, wallContainerView.frame.size.height)];
                         [searchContainerView setFrame:CGRectMake(2 * self.view.frame.size.width, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, searchContainerView.frame.size.height)];
                         [actionView.profileBackgroundView setBackgroundColor:[UIColor blackColor]];
                         [actionView.wallBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [actionView.searchBackgroundView setBackgroundColor:[UIColor whiteColor]];
                     }
     ];
    
    [actionView.profileButton setSelected:YES];
    [actionView.wallButton setSelected:NO];
    [actionView.searchButton setSelected:NO];
    
    [profileContainerView setHidden:NO];
    [wallContainerView setHidden:YES];
    [searchContainerView setHidden:YES];
    
    profileVC.myProfile = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_performReloadCall) object:nil];
    [self performSelector:@selector(_performReloadCall) withObject:nil afterDelay:0.5];
//    if ([userProf.spokesArray count] > 0)
//    {
//        profileVC.currentSpokenArray = [NSMutableArray arrayWithArray:userProf.spokesArray];
//        [profileVC.spokesTableView reloadData];
//    }
//    else
    {
//        [profileVC reloadMySpokesArray];
    }

}

- (IBAction)wallButtonPressed:(id)sender
{
    if (actionView.wallButton.selected)
    {
        return;
    }
    [UIView animateWithDuration:.25
                     animations:^{
                         [profileContainerView setFrame:CGRectMake(-self.view.frame.size.width, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, profileContainerView.frame.size.height)];
                         [wallContainerView setFrame:CGRectMake(0, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, wallContainerView.frame.size.height)];
                         [searchContainerView setFrame:CGRectMake(self.view.frame.size.width, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, searchContainerView.frame.size.height)];
                         [actionView.profileBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [actionView.wallBackgroundView setBackgroundColor:[UIColor blackColor]];
                         [actionView.searchBackgroundView setBackgroundColor:[UIColor whiteColor]];
                     }
     ];
    [actionView.profileButton setSelected:NO];
    [actionView.wallButton setSelected:YES];
    [actionView.searchButton setSelected:NO];
    
    [profileContainerView setHidden:YES];
    [wallContainerView setHidden:NO];
    [searchContainerView setHidden:YES];

    profileVC.myProfile = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_performReloadCall) object:nil];
    [self performSelector:@selector(_performReloadCall) withObject:nil afterDelay:0.5];
    
//    if ([userProf.cacheSpokesArray count] > 0)
    {
//        [wallVC loadWallSpokes];
    }
}

- (IBAction)searchButtonPressed:(id)sender
{
    if (actionView.searchButton.selected)
    {
        return;
    }
    
    [UIView animateWithDuration:.25
                     animations:^{
                         [profileContainerView setFrame:CGRectMake(-2 *self.view.frame.size.width, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, profileContainerView.frame.size.height)];
                         [wallContainerView setFrame:CGRectMake(-self.view.frame.size.width, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, wallContainerView.frame.size.height)];
                         [searchContainerView setFrame:CGRectMake(0, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, searchContainerView.frame.size.height)];
                         [actionView.profileBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [actionView.wallBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [actionView.searchBackgroundView setBackgroundColor:[UIColor blackColor]];
                     }
     ];
    
    [actionView.profileButton setSelected:NO];
    [actionView.wallButton setSelected:NO];
    [actionView.searchButton setSelected:YES];
    profileVC.myProfile = NO;
    [profileContainerView setHidden:YES];
    [wallContainerView setHidden:YES];
    [searchContainerView setHidden:NO];
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"profileAction"])
    {
        profileVC = [segue destinationViewController];
        profileVC.mainVC = self;
    }
    else if([segue.identifier isEqualToString:@"wallAction"])
    {
        wallVC = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
        wallVC.mainVC = self;
    }
    else if ([segue.identifier isEqualToString:@"userProfileAction"])
    {
        [actionView removeFromSuperview];
        ProfileViewController *profVC = [segue destinationViewController];
        profVC.userImageLoad = [UIImage imageWithData:currentSpokeChoose.ownerImageData];
        profVC.userName = [NSString stringWithFormat:@"%@ %@",currentSpokeChoose.ownerName, currentSpokeChoose.ownerSurname];
        profVC.userId = currentSpokeChoose.ownerID;
        profVC.userProfile = YES;
        profVC.mainVC = self;
        currentSpokeChoose = nil;
    }
    else if ([segue.identifier isEqualToString:@"respokenAction"])
    {
        [actionView removeFromSuperview];
        RespokenViewController *respokenVC = [segue destinationViewController];
        respokenVC.userImageLoad = [UIImage imageWithData:currentSpokeChoose.ownerImageData];
        respokenVC.userName = [NSString stringWithFormat:@"%@ %@",currentSpokeChoose.ownerName, currentSpokeChoose.ownerSurname];
        respokenVC.userId = currentSpokeChoose.ownerID;
        respokenVC.currentSpoke = currentSpokeChoose;
        respokenVC.mainVC = self;
        currentSpokeChoose = nil;
    }
}

-(void)_performReloadCall
{
    if ([actionView.profileButton isSelected])
    {
//        [[NSNotificationCenter defaultCenter]removeObserver:wallVC name:RELOAD_SPOKES_LIST object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:profileVC selector:@selector(loadSpokesTableView) name:RELOAD_SPOKES_LIST object:nil];
        NSLog(@"*************");
        NSLog(@"MY PROFILE");
        NSLog(@"*************");
        [profileVC loadSpokesTableView];
        
    }
    else if([actionView.wallButton isSelected])
    {
//        [[NSNotificationCenter defaultCenter]removeObserver:profileVC name:RELOAD_SPOKES_LIST object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:wallVC selector:@selector(loadWallSpokes) name:RELOAD_SPOKES_LIST object:nil];
        NSLog(@"------------------");
        NSLog(@"WALL VIEW");
        NSLog(@"------------------");
        [wallVC loadWallSpokes];
    }
}

-(void)openUserProfile:(Spoke*)sender
{
    currentSpokeChoose = (Spoke*)sender;
    if ([currentSpokeChoose.ownerID isEqualToString:[[UserProfile sharedProfile] getUserID]])
    {
        [self profileButtonPressed:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"userProfileAction" sender:nil];
    }
}

-(void)openRespokenView:(Spoke*)sender
{
    currentSpokeChoose = (Spoke*)sender;
    [self performSegueWithIdentifier:@"respokenAction" sender:nil];
}

-(void)addPlayBarView:(UIViewController*)currentVC withSpokeCell:(SpokeCell*)cell
{
    [UIView animateWithDuration:0.25 animations:^{
        [playBar setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - playBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20, playBar.frame.size.width, playBar.frame.size.height)];
    }completion:^(BOOL finished){
    }];
    Spoke *currentSpoke = cell.currentSpoke;
    [playBar.nameLabel setText:currentSpoke.ownerName];
    playBar.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    playBar.currentPlayingSpokeCell = cell;
    [playBar.playButton setSelected:NO];
    
    if ([currentVC isKindOfClass:[ProfileViewController class]])
    {
        playBar.profileVC = (ProfileViewController*)currentVC;
        playBar.wallVC = nil;
        playBar.respokenVC = nil;
    }
    else if ([currentVC isKindOfClass:[WallViewController class]])
    {
        playBar.wallVC = (WallViewController*)currentVC;
        playBar.respokenVC = nil;
        playBar.profileVC = nil;
    }
}

-(void)hidePlayBarView:(UIViewController*)currentVC withSpokeCell:(SpokeCell*)cell
{
    [UIView animateWithDuration:0.25 animations:^{
        [playBar setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20, playBar.frame.size.width, playBar.frame.size.height)];
    }completion:^(BOOL finished){
    }];
}

-(void)updateSlider
{
    [playBar updateSlider];
}

@end
