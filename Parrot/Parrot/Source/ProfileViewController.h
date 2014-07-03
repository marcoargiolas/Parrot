//
//  ProfileViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 01/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"

@interface ProfileViewController : UIViewController
{
    NSMutableDictionary *profile;
    IBOutlet UIButton *recordButton;
    IBOutlet UIView *buttonContainerView;
    IBOutlet UIView *contactsContainerView;
    IBOutlet UIView *headerContainerView;
    IBOutlet UILabel *infoLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UIImageView *userImageView;
}

@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@end
