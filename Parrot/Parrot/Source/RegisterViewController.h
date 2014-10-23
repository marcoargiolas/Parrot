//
//  RegisterViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 04/10/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
{
   BOOL userInsertedImage;
    NSData *imageData;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *termsButton;
@property (strong, nonatomic) IBOutlet UIButton *privacyButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;


- (IBAction)addImageButtonPressed:(id)sender;
- (IBAction)termsButtonPressed:(id)sender;
- (IBAction)privacyButtonPressed:(id)sender;
- (IBAction)registerButtonPressed:(id)sender;

@end
