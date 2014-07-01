//
//  MainViewController.h
//  Parrot
//
//  Created by Marco Argiolas on 30/06/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate>
{
    IBOutlet UIView *searchContainerView;
    IBOutlet UIView *wallContainerView;
    IBOutlet UIView *profileContainerView;
    IBOutlet UIButton *profileButton;
    IBOutlet UIButton *wallButton;
    IBOutlet UIButton *searchButton;
}

@property (strong, nonatomic) IBOutlet UIView *profileContainerView;
@property (strong, nonatomic) IBOutlet UIView *wallContainerView;
@property (strong, nonatomic) IBOutlet UIView *searchContainerView;

- (IBAction)profileButtonPressed:(id)sender;
- (IBAction)wallButtonPressed:(id)sender;
- (IBAction)searchButtonPressed:(id)sender;


@end
