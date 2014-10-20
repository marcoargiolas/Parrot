//
//  EnterViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 16/10/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;

- (IBAction)loginButtonPressed:(id)sender;

@end
