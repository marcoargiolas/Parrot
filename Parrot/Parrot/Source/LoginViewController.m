//
//  ViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "UserProfile.h"
#import "GlobalDefines.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[activityIndicator removeFromSuperview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToMainView) name:PROFILE_LOADED_FROM_FACEBOOK object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:PROFILE_LOADED_FROM_FACEBOOK object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonPressed:(id)sender
{
    [self.view addSubview:activityIndicator];
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"user_education_history", @"user_events", @"user_hometown", @"user_interests", @"user_status", @"user_website", @"user_work_history", @"user_photos"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [activityIndicator stopAnimating]; // Hide loading indicator
        
        UserProfile *profile = [UserProfile sharedProfile];
        if (!user)
        {
            if (!error)
            {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            else
            {
                NSLog(@"Uh oh. An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }
        else if (user.isNew)
        {
            NSLog(@"User with facebook signed up and logged in!");
            [profile loadProfileFromFacebook];
        }
        else
        {
            NSLog(@"User with facebook logged in!");
            [profile loadProfileFromFacebook];
        }
    }];
    
    [activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)goToMainView
{
    [self performSegueWithIdentifier:@"loginAction" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"loginAction"])
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ParrotNavigationController *controller = [storyBoard  instantiateViewControllerWithIdentifier:@"ParrotNavigationController"];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"background_navbar@2x.png"] forBarMetrics:UIBarMetricsDefault];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = controller;
    }
}

@end
