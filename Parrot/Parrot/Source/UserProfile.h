//
//  UserProfile.h
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Spoke.h"

@interface UserProfile : NSObject
{
    PFUser *currentUser;
    NSMutableArray *spokesArray;
}

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *spokesArray;

+(UserProfile*)sharedProfile;
- (void) loadProfileFromFacebook;

@end
