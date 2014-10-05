//
//  LoginViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
- (IBAction)facebookLoginButtonPressed:(id)sender;
- (IBAction)registerButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
