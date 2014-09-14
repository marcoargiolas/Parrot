//
//  AppDelegate.h
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParrotNavigationController.h"
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import "UserProfile.h"
#import "MainViewController.h"
#import "GlobalDefines.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UserProfile *userProf;
}
@property (strong, nonatomic) UIWindow *window;

@end
