//
//  RegisterViewController.m
//  Parrot
//
//  Created by Marco Argiolas on 04/10/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIImage+Additions.h"
#import <Parse/Parse.h>
#import "UserProfile.h"
#import "GlobalDefines.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

@synthesize addImageButton;
@synthesize registerButton;
@synthesize userNameTextField;
@synthesize passwordTextField;
@synthesize emailTextField;
@synthesize termsButton;
@synthesize privacyButton;
@synthesize containerScrollView;
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];

    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, registerButton.frame.origin.y + registerButton.frame.size.height + 20);
    
    [addImageButton.layer setCornerRadius:addImageButton.frame.size.width/2];
    [addImageButton.layer setMasksToBounds:YES];
    [addImageButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [addImageButton.layer setShadowRadius:2.0];
    [addImageButton.layer setBorderWidth:1.0];
    
    [registerButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    registerButton.layer.cornerRadius = 2;
    [registerButton.layer setShadowRadius:2.0];
    [registerButton.layer setBorderWidth:1];
    
    NSMutableAttributedString *termsString = [[NSMutableAttributedString alloc] initWithString:@"Terms of Service"];
    [termsString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [termsString length])];
    [termsButton setAttributedTitle:termsString forState:UIControlStateNormal];
    
    NSMutableAttributedString *privacyString = [[NSMutableAttributedString alloc] initWithString:@"Privacy Policy"];
    [privacyString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [privacyString length])];
    [privacyButton setAttributedTitle:privacyString forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    [activityIndicator removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if (theTextField == userNameTextField)
    {
        [emailTextField becomeFirstResponder];
    }
    if (theTextField == emailTextField)
    {
        [passwordTextField becomeFirstResponder];
    }
    if (theTextField == passwordTextField)
    {
        [passwordTextField resignFirstResponder];
        [self registerAction];
    }
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

    if([userNameTextField isFirstResponder])
    {
        [containerScrollView scrollRectToVisible:CGRectMake(0, userNameTextField.frame.origin.y + userNameTextField.frame.size.height, containerScrollView.frame.size.width, containerScrollView.frame.size.height) animated:YES];
    }
    if([emailTextField isFirstResponder])
    {
        [containerScrollView scrollRectToVisible:CGRectMake(0, emailTextField.frame.origin.y + emailTextField.frame.size.height, containerScrollView.frame.size.width, containerScrollView.frame.size.height) animated:YES];
    }
    if([passwordTextField isFirstResponder])
    {
        [containerScrollView scrollRectToVisible:CGRectMake(0, passwordTextField.frame.origin.y + passwordTextField.frame.size.height, containerScrollView.frame.size.width, containerScrollView.frame.size.height) animated:YES];
    }

    [UIView commitAnimations];
}

- (void)keyboardWasHidden:(NSNotification *)aNotification
{
    NSTimeInterval animationDuration = 0.2;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, registerButton.frame.origin.y + registerButton.frame.size.height + 20);
    
    [UIView commitAnimations];
}

#pragma mark ActionSheet and AlertView Delegate Methods

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==2)
        return;
    
    if(buttonIndex==1 && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //not available
        UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Camera is not available", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alertView2 show];
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if(buttonIndex==0)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if(buttonIndex==1)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"BUTTON INDEX %d", buttonIndex);
    switch (buttonIndex)
    {
            //Change
        case 0:
            break;
        case 1:
            [self registerAction];
            break;
        default:
            break;
    }
}

- (IBAction)termsButtonPressed:(id)sender {
}

- (IBAction)privacyButtonPressed:(id)sender {
}

- (IBAction)registerButtonPressed:(id)sender
{
    UIAlertView *alert;
    if (imageData == nil)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please choose your image" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else if ([userNameTextField.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your username" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else if ([emailTextField.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your email" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else if ([passwordTextField.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your password" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Is This Correct ?" message:[NSString stringWithFormat:@"You entered your email as: %@", emailTextField.text]  delegate:self cancelButtonTitle:@"Change" otherButtonTitles:@"Ok", nil];
    }
    [alert show];
}

-(void) registerAction
{
    UIAlertView *alert;
    PFUser *user = [PFUser user];
    if (imageData == nil)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please choose your image" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else if ([userNameTextField.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your username" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else if ([emailTextField.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your email" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    else if ([passwordTextField.text length] == 0)
    {
        alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please insert your password" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    }
    if(alert != nil)
        [alert show];
    else
    {
        UIView *loadingView = [[UIView alloc]initWithFrame:self.view.frame];
        [loadingView setBackgroundColor:[UIColor grayColor]];
        [loadingView setAlpha:0.5];
        [self.view addSubview:loadingView];
        [userNameTextField resignFirstResponder];
        [emailTextField resignFirstResponder];
        [passwordTextField resignFirstResponder];
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        user.username = emailTextField.text;
        user.password = passwordTextField.text;
        user.email = emailTextField.text;
        
        // other fields can be set just like with PFObject
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                NSLog(@"LOGGED IN");
                UserProfile *userProf = [UserProfile sharedProfile];
                userProf.currentUser = [PFUser currentUser];
                userProf.spokesArray = [[NSMutableArray alloc]init];
                NSMutableDictionary *currentProfile = [[NSMutableDictionary alloc] init];
                
                [currentProfile setObject:userNameTextField.text forKey:USER_FULL_NAME];
                [currentProfile setObject:imageData forKey:USER_IMAGE_DATA];
                
                [userProf.currentUser setObject:userProf.spokesArray forKey:USER_SPOKES_ARRAY];
                [userProf.currentUser setObject:userNameTextField.text forKey:USER_FULL_NAME];
                
                [userProf.currentUser setObject:currentProfile forKey:USER_PROFILE];
                
                PFFile *ownerImage = [PFFile fileWithData:imageData];
                [userProf.currentUser setObject:ownerImage forKey:@"userImage"];
                
                PFObject *userImage = [PFObject objectWithClassName:@"User"];
                [userImage setObject:ownerImage forKey:@"userImage"];
                [userImage setObject:user forKey:@"User"];
                [userImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error)
                    {
                        NSLog(@"SAVE");
                        [userProf.currentUser saveInBackground];
                        //            [self updateProfile];
                        [[NSNotificationCenter defaultCenter]postNotificationName:PROFILE_LOADED_FROM_FACEBOOK object:nil];
                        [[NSUserDefaults standardUserDefaults] setObject:[userProf.currentUser objectId] forKey:USER_ID];
                        [userProf saveProfileLocal];
                        [activityIndicator stopAnimating];
                        [activityIndicator removeFromSuperview];
                        [loadingView removeFromSuperview];
                    }
                    else
                    {
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alertView show];
                        [activityIndicator stopAnimating];
                        [activityIndicator removeFromSuperview];
                        [loadingView removeFromSuperview];
                    }
                }];
            }
            else
            {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"ERROR STRING %@", errorString);
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                [loadingView removeFromSuperview];
            }
        }];
    }
}
#pragma mark image management
- (IBAction)addImageButtonPressed:(id)sender
{
    UIActionSheet *profileImageActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"From Memory", @""), NSLocalizedString(@"From Camera", @""), nil];
    
    [profileImageActionSheet showInView:self.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    CGSize sz = CGSizeMake(100, 100);
    UIGraphicsBeginImageContext(sz);
    [image drawInRect:CGRectMake(0,0,100,100)];
    UIImage *im2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [addImageButton setBackgroundImage:im2 forState:UIControlStateNormal];
    [addImageButton setTitle:@"" forState:UIControlStateNormal];
    userInsertedImage = YES;
    
    if(image != nil)
    {
        imageData = UIImagePNGRepresentation(im2);
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
