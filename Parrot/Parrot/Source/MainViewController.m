//
//  MainViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize profileContainerView;
@synthesize wallContainerView;
@synthesize searchContainerView;
@synthesize profileBackgroundView;
@synthesize wallBackgroundView;
@synthesize searchBackgroundView;

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
    [profileContainerView setFrame:CGRectMake(profileContainerView.frame.origin.x, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 60)];
    [wallContainerView setFrame:CGRectMake(wallContainerView.frame.origin.x, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 60)];
    [searchContainerView setFrame:CGRectMake(searchContainerView.frame.origin.x, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 60)];
    

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

    [self profileButtonPressed:nil];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
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
    if(profileButton.selected)
        return;
    if(wallButton.selected)
    {
        [self profileButtonPressed:nil];
        return;
    }
    if(searchButton.selected)
    {
        [self wallButtonPressed:nil];
        return;
    }
}

-(void) swipeLeft:(UISwipeGestureRecognizer *) recognizer
{
    if(profileButton.selected)
    {
        [self wallButtonPressed:nil];
        return;
    }
    if(wallButton.selected)
    {
        [self searchButtonPressed:nil];
        return;
    }
    if(searchButton.selected)
        return;
}

- (IBAction)profileButtonPressed:(id)sender
{
    if (profileButton.selected)
    {
        return;
    }
    
    [UIView animateWithDuration:.25
                     animations:^{
                         [profileContainerView setFrame:CGRectMake(0, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, profileContainerView.frame.size.height)];
                         [wallContainerView setFrame:CGRectMake(self.view.frame.size.width, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, wallContainerView.frame.size.height)];
                         [searchContainerView setFrame:CGRectMake(2 * self.view.frame.size.width, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, searchContainerView.frame.size.height)];
                         [profileBackgroundView setBackgroundColor:[UIColor blackColor]];
                         [wallBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [searchBackgroundView setBackgroundColor:[UIColor whiteColor]];
                     }
     ];
    
    [profileButton setSelected:YES];
    [wallButton setSelected:NO];
    [searchButton setSelected:NO];
    
    [profileContainerView setHidden:NO];
    [wallContainerView setHidden:YES];
    [searchContainerView setHidden:YES];
    
    profileVC.spokesTableView.delegate = profileVC;
    profileVC.spokesTableView.dataSource = profileVC;
    
    wallVC.wallTableView.delegate = nil;
    wallVC.wallTableView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadUserWall" object:nil];
}

- (IBAction)wallButtonPressed:(id)sender
{
    if (wallButton.selected)
    {
        return;
    }
    
    [UIView animateWithDuration:.25
                     animations:^{
                         [profileContainerView setFrame:CGRectMake(-self.view.frame.size.width, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, profileContainerView.frame.size.height)];
                         [wallContainerView setFrame:CGRectMake(0, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, wallContainerView.frame.size.height)];
                         [searchContainerView setFrame:CGRectMake(self.view.frame.size.width, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, searchContainerView.frame.size.height)];
                         [profileBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [wallBackgroundView setBackgroundColor:[UIColor blackColor]];
                         [searchBackgroundView setBackgroundColor:[UIColor whiteColor]];
                     }
     ];
    [profileButton setSelected:NO];
    [wallButton setSelected:YES];
    [searchButton setSelected:NO];
    
    [profileContainerView setHidden:YES];
    [wallContainerView setHidden:NO];
    [searchContainerView setHidden:YES];

    profileVC.spokesTableView.delegate = nil;
    profileVC.spokesTableView.dataSource = nil;
    
    wallVC.wallTableView.delegate = wallVC;
    wallVC.wallTableView.dataSource = wallVC;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"loadWallSpokes" object:nil];
}

- (IBAction)searchButtonPressed:(id)sender
{
    if (searchButton.selected)
    {
        return;
    }
    
    [UIView animateWithDuration:.25
                     animations:^{
                         [profileContainerView setFrame:CGRectMake(-2 *self.view.frame.size.width, profileContainerView.frame.origin.y, profileContainerView.frame.size.width, profileContainerView.frame.size.height)];
                         [wallContainerView setFrame:CGRectMake(-self.view.frame.size.width, wallContainerView.frame.origin.y, wallContainerView.frame.size.width, wallContainerView.frame.size.height)];
                         [searchContainerView setFrame:CGRectMake(0, searchContainerView.frame.origin.y, searchContainerView.frame.size.width, searchContainerView.frame.size.height)];
                         [profileBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [wallBackgroundView setBackgroundColor:[UIColor whiteColor]];
                         [searchBackgroundView setBackgroundColor:[UIColor blackColor]];
                     }
     ];
    
    [profileButton setSelected:NO];
    [wallButton setSelected:NO];
    [searchButton setSelected:YES];
    
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
    if([segue.identifier isEqualToString:@"wallAction"])
    {
        wallVC = [segue destinationViewController];
    }
}
@end
