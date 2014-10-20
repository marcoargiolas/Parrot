//
//  EnterViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 16/10/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "EnterViewController.h"
#import <Parse/Parse.h>
#import "UserProfile.h"
#import "GlobalDefines.h"

@interface EnterViewController ()

@end

@implementation EnterViewController

@synthesize loginButton;
@synthesize usernameTextfield;
@synthesize passwordTextfield;
@synthesize containerScrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, containerScrollView.frame.size.height);
    
    [loginButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    loginButton.layer.cornerRadius = 2;
    [loginButton.layer setShadowRadius:2.0];
    [loginButton.layer setBorderWidth:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == usernameTextfield)
    {
        [passwordTextfield becomeFirstResponder];
    }
    else
        [theTextField resignFirstResponder];

    return YES;
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    NSTimeInterval animationDuration = 0.2;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, containerScrollView.frame.size.height + keyboardSize.height);
    
    //    if([userNameTextField isFirstResponder])
    //    {
    //        [containerScrollView scrollRectToVisible:CGRectMake(0, userNameTextField.frame.origin.y + userNameTextField.frame.size.height, containerScrollView.frame.size.width, containerScrollView.frame.size.height) animated:YES];
    //    }
    
    if([passwordTextfield isFirstResponder])
    {
        [containerScrollView scrollRectToVisible:CGRectMake(0, passwordTextfield.frame.origin.y + passwordTextfield.frame.size.height, containerScrollView.frame.size.width, containerScrollView.frame.size.height) animated:YES];
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWasHidden:(NSNotification *)aNotification
{
    NSTimeInterval animationDuration = 0.2;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, containerScrollView.frame.size.height);
    
    [UIView commitAnimations];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonPressed:(id)sender
{
    UIAlertView *alert;
    if ([usernameTextfield.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your username" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else if ([passwordTextfield.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your password" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    if(alert != nil)
        [alert show];
    else
    {
        [PFUser logInWithUsernameInBackground:usernameTextfield.text password:passwordTextfield.text block:^(PFUser *user, NSError *error) {
            if (user)
            {
                NSLog(@"USER %@", user);
                NSMutableDictionary *currentProfile = [[NSMutableDictionary alloc] init];
                
                UserProfile *userProf = [UserProfile sharedProfile];
                userProf.currentUser = [PFUser currentUser];
                userProf.spokesArray = [[NSMutableArray alloc]init];
                
                [currentProfile setObject:user.objectId forKey:USER_ID];

                if (user.username != nil)
                {
                    [currentProfile setObject:user.username forKey:USER_FULL_NAME];
                }
                
                NSData *imageData;
                if ([user objectForKey:@"userImage"] != nil)
                {
                    PFFile *imageFile = [user objectForKey:@"userImage"];
                    imageData = [imageFile getData];
                    [currentProfile setObject:imageData forKey:USER_IMAGE_DATA];
                }
                
                [userProf.currentUser setObject:imageData forKey:@"userImage"];

                [userProf.currentUser setObject:currentProfile forKey:USER_PROFILE];
                
                [userProf.currentUser saveInBackground];
                //            [self updateProfile];
                [[NSNotificationCenter defaultCenter]postNotificationName:PROFILE_LOADED_FROM_FACEBOOK object:nil];
                [[NSUserDefaults standardUserDefaults] setObject:[userProf.currentUser objectId] forKey:USER_ID];
                [userProf saveProfileLocal];
            }
            else
            {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"ERROR STRING %@", errorString);
            }
            
        }];
    }
}
@end
