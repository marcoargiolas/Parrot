//
//  MainViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "MainViewController.h"
#import "ParrotNavigationController.h"

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
    [profileContainerView setFrame:CGRectMake(profileContainerView.frame.origin.x, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    [wallContainerView setFrame:CGRectMake(wallContainerView.frame.origin.x, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    [searchContainerView setFrame:CGRectMake(searchContainerView.frame.origin.x, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height)];
    

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    swipeLeft.delegate = self;
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    swipeRight.delegate = self;
    
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
    [self wallButtonPressed:nil];
        
    [self.navigationController.navigationBar addSubview:actionView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar addSubview:actionView];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"background_navbar@2x.png"] forBarMetrics:UIBarMetricsDefault];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

-(void) swipeRight:(UISwipeGestureRecognizer *) recognizer
{
    if(actionView.profileButton.selected)
        return;
    if(actionView.wallButton.selected)
    {
        [self profileButtonPressed:nil];
        return;
    }
    if(actionView.searchButton.selected)
    {
        [self wallButtonPressed:nil];
        return;
    }
}

-(void) swipeLeft:(UISwipeGestureRecognizer *) recognizer
{
    if(actionView.profileButton.selected)
    {
        [self wallButtonPressed:nil];
        return;
    }
    if(actionView.wallButton.selected)
    {
        [self searchButtonPressed:nil];
        return;
    }
    if(actionView.searchButton.selected)
        return;
}

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
    
    profileVC.spokesTableView.delegate = profileVC;
    profileVC.spokesTableView.dataSource = profileVC;
    profileVC.myProfile = YES;
    wallVC.wallTableView.delegate = nil;
    wallVC.wallTableView.dataSource = nil;

    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadUserWall" object:nil];
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

    profileVC.spokesTableView.delegate = nil;
    profileVC.spokesTableView.dataSource = nil;
    profileVC.myProfile = NO;
    wallVC.wallTableView.delegate = wallVC;
    wallVC.wallTableView.dataSource = wallVC;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadWallSpokes" object:nil];
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
    }
    else if([segue.identifier isEqualToString:@"wallAction"])
    {
        wallVC = [[[segue destinationViewController] viewControllers] objectAtIndex:0];
    }
    else if ([segue.identifier isEqualToString:@"userProfileAction"])
    {
        [actionView removeFromSuperview];
        ProfileViewController *profVC = [segue destinationViewController];
        profVC.userProfile = YES;
        profVC.userImageLoad = [UIImage imageWithData:currentSpokeChoose.ownerImageData];
        profVC.userName = [NSString stringWithFormat:@"%@ %@",currentSpokeChoose.ownerName, currentSpokeChoose.ownerSurname];
        profVC.userId = currentSpokeChoose.ownerID;
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
        
        currentSpokeChoose = nil;
    }
}

-(void)openUserProfile:(Spoke*)sender
{
    currentSpokeChoose = (Spoke*)sender;
    [self performSegueWithIdentifier:@"userProfileAction" sender:nil];
}

-(void)openRespokenView:(Spoke*)sender
{
    currentSpokeChoose = (Spoke*)sender;
    [self performSegueWithIdentifier:@"respokenAction" sender:nil];
}

@end
