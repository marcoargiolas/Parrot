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

@interface UserProfile : NSObject <PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate>
{
    PFUser *currentUser;
    NSMutableArray *spokesArray;
}

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *spokesArray;

+(UserProfile*)sharedProfile;
- (void) loadProfileFromFacebook;
-(NSString*)getUserID;
- (void)saveProfileLocal;
- (void)loadProfileLocal;
-(void)saveSpokesArrayRemote:(Spoke*)spokeToSave;
-(void)updateTotalSpokeLike:(NSString*)spokeID thanksID:(NSString*)userThanksID addLike:(BOOL)like totalLikes:(int)totalLikes;
-(Spoke*)getSpokeWithID:(NSString*)spokeID;
-(void)updateTotalSpokeHeard:(NSString*)spokeID heardID:(NSString*)userHeardID;
-(void)deleteSpoke:(Spoke*)spokeToDelete;
-(BOOL)spokeAlreadyListened:(Spoke*)spokeToCheck;
-(NSMutableArray*)loadAllSpokesFromRemote;
-(NSMutableArray*)loadSpokesFromRemoteForUser:(NSString*)userID;

@end
