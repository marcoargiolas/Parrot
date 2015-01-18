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

typedef enum
{
    firstSpoke = 0,
    allSpoke,
    mySpoke,
    otherUserSpoke
} spokeType;

@interface UserProfile : NSObject <PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate>
{
    PFUser *currentUser;
    NSMutableArray *spokesArray;
    NSMutableArray *cacheSpokesArray;
    NSMutableArray *firstResultsArray;
    NSMutableArray *allResultsArray;
    NSMutableArray *currentUserSpokesArray;
    int allResultObjectsCount;
    int mySpokesCount;
    int otherUserSpokesCount;
}

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *spokesArray;
@property (nonatomic, strong) NSMutableArray *cacheSpokesArray;
@property (nonatomic, strong) NSMutableArray *currentUserSpokesArray;

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
-(void)loadAllSpokesFromRemote;
-(void)loadFirstResults:(int)resultsNumber;
-(NSMutableArray*)loadSpokesFromRemoteForUser:(NSString*)userID;
-(void)loadBioFromRemoteForUser:(NSString*)userID;
-(void)respokenForSpokeID:(NSString*)spokeID;
-(void)updateRespokenList:(NSString*)spokeID respokeID:(NSString*)respokeID removeRespoken:(BOOL)remove;
-(void)saveHashTagToRemote:(NSMutableArray*)hashTagArray;
//CACHE MANAGEMENT
-(void)saveLocalSpokesCache:(NSMutableArray*)arrivedSpokesArray;
- (void)loadLocalSpokesCache;

@end
