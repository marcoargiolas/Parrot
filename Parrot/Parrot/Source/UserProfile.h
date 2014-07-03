//
//  UserProfile.h
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface UserProfile : NSObject
{
   PFUser *currentUser;
}

@property (nonatomic, strong) PFUser *currentUser;

+(UserProfile*)sharedProfile;
- (void) loadProfileFromFacebook;

@end
