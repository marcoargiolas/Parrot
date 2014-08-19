//
//  UserProfile.m
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "UserProfile.h"
#import "GlobalDefines.h"

static UserProfile *shared = nil;

@implementation UserProfile

@synthesize currentUser;
@synthesize spokesArray;

+(UserProfile*)sharedProfile
{
    @synchronized(shared) {
		if(!shared || shared == NULL)
        {
			// allocate the shared instance, because it hasn't been done yet
			shared = [[self alloc] init];
		}
		return shared;
	}
}

- (void)loadProfileLocal
{
    //Check backward compatibility
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:userID];
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"profile.plist"];
    NSString *spokesPath = [documentsDirectory stringByAppendingPathComponent:@"spokes.plist"];
	if(![[NSFileManager defaultManager] fileExistsAtPath:finalPath])
    {
		NSString *path = [[NSBundle mainBundle] bundlePath];
		finalPath = [path stringByAppendingPathComponent:@"profile.plist"];
	}
    if(currentUser == nil)
    {
        currentUser = [[PFUser alloc]init];
        spokesArray = [[NSMutableArray alloc]init];
    }
	[currentUser setObject:[NSMutableDictionary dictionaryWithContentsOfFile:finalPath] forKey:USER_PROFILE];
    NSData *peopleData = [NSData dataWithContentsOfFile:spokesPath];
    spokesArray = [NSKeyedUnarchiver unarchiveObjectWithData:peopleData];
}

- (void)saveProfileLocal
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self getUserID]];
	NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"profile.plist"];
    NSString *spokesPath = [documentsDirectory stringByAppendingPathComponent:@"spokes.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:finalPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:spokesPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }

    if(currentUser != nil)
    {
        [[currentUser objectForKey:USER_PROFILE] writeToFile:finalPath atomically:NO];
    
        NSData *spokesData = [NSKeyedArchiver archivedDataWithRootObject:spokesArray];
        [spokesData writeToFile:spokesPath atomically:NO];
    }
}

- (void) loadProfileFromFacebook
{
    if(currentUser == nil)
    {
        currentUser = [PFUser currentUser];
        spokesArray = [[NSMutableArray alloc]init];
    }
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error)
        {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *currentProfile = [[NSMutableDictionary alloc] init];
            
            if (facebookID)
            {
                currentProfile[USER_ID] = facebookID;
            }

            NSString *userName;
            if (userData[@"name"])
            {
                userName = userData[@"name"];
                currentProfile[USER_FULL_NAME] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                currentProfile[USER_LOCATION] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                currentProfile[USER_GENDER] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                currentProfile[USER_BIRTHDAY] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                currentProfile[USER_RELATIONSHIP] = userData[@"relationship_status"];
            }
            
            NSString *bio;
            if (userData[@"bio"])
            {
                bio = userData[@"bio"];
                currentProfile[USER_BIO] = userData[@"bio"];
            }
            
            NSData *imageData;
            if ([pictureURL absoluteString])
            {
                NSURL *imageUrl = [NSURL URLWithString:[pictureURL absoluteString]];
                imageData = [[NSData alloc]initWithContentsOfURL:imageUrl];
                
                currentProfile[USER_IMAGE_DATA] = imageData;
            }
            
            [currentUser setObject:currentProfile forKey:USER_PROFILE];
            [currentUser setObject:spokesArray forKey:USER_SPOKES_ARRAY];
            [currentUser setObject:userName forKey:@"fullName"];
            if([bio length] > 0)
                [currentUser setObject:bio forKey:@"bio"];
            PFFile *ownerImage = [PFFile fileWithData:imageData];
            [currentUser setObject:ownerImage forKey:@"userImage"];


            [currentUser saveInBackground];
//            [self updateProfile];
            [[NSNotificationCenter defaultCenter]postNotificationName:PROFILE_LOADED_FROM_FACEBOOK object:nil];
            [[NSUserDefaults standardUserDefaults] setObject:[currentUser objectId] forKey:USER_ID];
            [self saveProfileLocal];
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"])
        { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [PFUser logOut];
            
        }
        else
        {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

-(NSString*)getUserID
{
    return [[PFUser currentUser]objectId];
}

-(void)saveProfileRemote
{
    
}

-(void)saveSpokesArrayRemote:(Spoke*)spokeToSave
{
    PFObject *obj = [PFObject objectWithClassName:@"spoke"];
    [obj setObject:spokeToSave.spokeID forKey:@"spokeID"];
    [obj setObject:spokeToSave.creationDate forKey:@"creationDate"];
    [obj setObject:[NSString stringWithFormat:@"%d",spokeToSave.totalHeards] forKey:@"totalHeards"];
    PFFile *audioDataFile = [PFFile fileWithData:spokeToSave.audioData];
    [obj setObject:audioDataFile forKey:@"audioData"];
    [obj setObject:[NSString stringWithFormat:@"%d",spokeToSave.totalLikes] forKey:@"totalLikes"];
    [obj setObject:spokeToSave.respokeToSpokeID forKey:@"respokeToSpokeID"];
    [obj setObject:spokeToSave.ownerID forKey:@"ownerID"];
    [obj setObject:spokeToSave.listOfHeardsID forKey:@"listOfHeardsID"];
    [obj setObject:spokeToSave.listOfThankersID forKey:@"listOfThankersID"];
    [obj setObject:spokeToSave.listOfRespokeID forKey:@"listOfRespokeID"];
    PFFile *ownerImage = [PFFile fileWithData:spokeToSave.ownerImageData];
    [obj setObject:ownerImage forKey:@"ownerImageData"];
    [obj setObject:spokeToSave.ownerName forKey:@"ownerName"];
    
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loadWallSpokes" object:nil];
    }];
}

-(void)updateTotalSpokeLike:(NSString*)spokeID thanksID:(NSString*)userThanksID addLike:(BOOL)like totalLikes:(int)totalLikes
{
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query whereKey:@"spokeID" equalTo:spokeID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSMutableArray *thanksTempArray = [object objectForKey:@"listOfThankersID"];
                if(thanksTempArray == nil)
                {
                    thanksTempArray = [[NSMutableArray alloc]init];
                }
                NSLog(@"THANKS ARRAY %@", thanksTempArray);
                int remoteTotalLikes = [[object objectForKey:@"totalLikes"] intValue];
                if(remoteTotalLikes < totalLikes)
                {
                    [thanksTempArray addObject:userThanksID];
                }
                else
                {
                    [thanksTempArray removeObject:userThanksID];
                }
                
                [object setObject:[NSString stringWithFormat:@"%d",[thanksTempArray count]] forKey:@"totalLikes"];
                
                NSLog(@"THANKS ARRAY DOPO %@", thanksTempArray);
                [object setObject:thanksTempArray forKey:@"listOfThankersID"];
                [object saveInBackground];
                
                NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
                [userInfo setObject:[NSNumber numberWithBool:like] forKey:@"like"];
                [userInfo setObject:[NSNumber numberWithInt:totalLikes] forKey:@"totalLikes"];
                [nc postNotificationName:@"updateLikes" object:self userInfo:userInfo];
                
                break;
            }
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLikesError" object:nil];
        }
    }];
}

-(void)updateTotalSpokeHeard:(NSString*)spokeID heardID:(NSString*)userHeardID
{
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query whereKey:@"spokeID" equalTo:spokeID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSMutableArray *heardTempArray = [object objectForKey:@"listOfHeardsID"];

                if(![heardTempArray containsObject:[self getUserID]])
                {
                    int totalHeards = [[object objectForKey:@"totalHeards"] intValue];
                    totalHeards = totalHeards + 1;
                    [object setObject:[NSString stringWithFormat:@"%d",totalHeards] forKey:@"totalHeards"];
                    if(heardTempArray == nil)
                    {
                        heardTempArray = [[NSMutableArray alloc]init];
                    }
                    [heardTempArray addObject:userHeardID];
                    [object setObject:heardTempArray forKey:@"listOfHeardsID"];
                    [object saveInBackground];
//                    if([userHeardID isEqualToString:[self getUserID]])
//                    {
//                        Spoke *tempSpoke = [self getSpokeWithID:spokeID];
//                        [spokesArray removeObject:[self getSpokeWithID:spokeID]];
//                        tempSpoke.totalHeards = 1;
//                        tempSpoke.listOfHeardsID = heardTempArray;
//                        [spokesArray addObject:tempSpoke];
//                        [self saveProfileLocal];
//                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHeards" object:self userInfo:nil];
                    break;
                }
            }
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)updateRespokenList:(NSString*)spokeID respokeID:(NSString*)respokeID
{
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query whereKey:@"spokeID" equalTo:spokeID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                NSMutableArray *respokeTempArray = [object objectForKey:@"listOfRespokeID"];
                
                if(![respokeTempArray containsObject:[self getUserID]])
                {
                    if(respokeTempArray == nil)
                    {
                        respokeTempArray = [[NSMutableArray alloc]init];
                    }
                    [respokeTempArray addObject:respokeID];
                    [object setObject:respokeTempArray forKey:@"listOfRespokeID"];
                    [object saveInBackground];
                    //                    if([userHeardID isEqualToString:[self getUserID]])
                    //                    {
                    //                        Spoke *tempSpoke = [self getSpokeWithID:spokeID];
                    //                        [spokesArray removeObject:[self getSpokeWithID:spokeID]];
                    //                        tempSpoke.totalHeards = 1;
                    //                        tempSpoke.listOfHeardsID = heardTempArray;
                    //                        [spokesArray addObject:tempSpoke];
                    //                        [self saveProfileLocal];
                    //                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHeards" object:self userInfo:nil];
                    break;
                }
            }
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(NSMutableArray*)loadSpokesFromRemoteForUser:(NSString*)userID
{
    NSMutableArray *resultsArray = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query whereKey:@"ownerID" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                [resultsArray addObject:[self spokeObjectfromPFObject:object]];
            }

            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:resultsArray forKey:SPOKEN_ARRAY_ARRIVED];
            [[NSNotificationCenter defaultCenter]postNotificationName:USER_WALL_SPOKEN_ARRIVED object:nil userInfo:userInfo];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    return resultsArray;
}

-(void)loadBioFromRemoteForUser:(NSString*)userID
{
    __block NSString *resultString = @"";
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"objectId" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                if([object objectForKey:@"bio"] != nil)
                    resultString = [object objectForKey:@"bio"];
           
            }
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:resultString forKey:BIO_ARRIVED];
            [[NSNotificationCenter defaultCenter]postNotificationName:BIO_LOADED object:nil userInfo:userInfo];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)respokenForSpokeID:(NSString*)spokeID
{
     __block NSMutableArray *resultsArray = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query whereKey:@"respokeToSpokeID" equalTo:spokeID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                [resultsArray addObject:[self spokeObjectfromPFObject:object]];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"wallSpokesArrived" object:nil];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:resultsArray forKey:RESPOKEN_ARRAY];
            [[NSNotificationCenter defaultCenter]postNotificationName:RESPOKEN_ARRAY_ARRIVED object:nil userInfo:userInfo];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


-(NSMutableArray*)loadAllSpokesFromRemote
{
    NSMutableArray *resultsArray = [[NSMutableArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                [resultsArray addObject:[self spokeObjectfromPFObject:object]];
            }
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"wallSpokesArrived" object:nil];
        }
        else
        {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    return resultsArray;
}


-(void)deleteSpoke:(Spoke*)spokeToDelete
{
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query whereKey:@"spokeID" equalTo:spokeToDelete.spokeID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            for (PFObject *object in objects)
            {
                [object deleteEventually];
                [self saveProfileLocal];
            }
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(Spoke*)getSpokeWithID:(NSString*)spokeID
{
    Spoke *spokeRequested = nil;
    for(Spoke *temp in spokesArray)
    {
        if([temp.spokeID isEqualToString:spokeID])
            spokeRequested = temp;
    }
    return spokeRequested;
}

-(BOOL)spokeAlreadyListened:(Spoke*)spokeToCheck
{
    NSMutableArray *heardArray = spokeToCheck.listOfHeardsID;
    for (NSString *userID in heardArray)
    {
        if([userID isEqualToString:[self getUserID]])
            return YES;
    }
    return NO;
}

-(Spoke*)spokeObjectfromPFObject:(PFObject*)object
{
    Spoke *spokeObj = [[Spoke alloc]init];
    spokeObj.ownerID = [object objectForKey:@"ownerID"];
    spokeObj.spokeID = [object objectForKey:@"spokeID"];
    spokeObj.creationDate = [object objectForKey:@"creationDate"];
    spokeObj.respokeToSpokeID = [object objectForKey:@"respokeToSpokeID"];
    spokeObj.totalHeards = [[object objectForKey:@"totalHeards"] intValue];
    spokeObj.totalLikes = [[object objectForKey:@"totalLikes"] intValue];
    spokeObj.listOfHeardsID = [object objectForKey:@"listOfHeardsID"];
    spokeObj.listOfThankersID = [object objectForKey:@"listOfThankersID"];
    spokeObj.listOfRespokeID = [object objectForKey:@"listOfRespokeID"];
    PFFile *audioFile = [object objectForKey:@"audioData"];
    spokeObj.audioData = [audioFile getData];
    spokeObj.ownerName = [object objectForKey:@"ownerName"];
    PFFile *ownerImage = [object objectForKey:@"ownerImageData"];
    spokeObj.ownerImageData = [ownerImage getData];

    return spokeObj;
}
//// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    NSLog(@"SIGN UP");
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

- (void)updateProfile {
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"location"]) {
//        [self.rowDataArray replaceObjectAtIndex:0 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"location"]];
//    }
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"gender"]) {
//        [self.rowDataArray replaceObjectAtIndex:1 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"gender"]];
//    }
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"birthday"]) {
//        [self.rowDataArray replaceObjectAtIndex:2 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"birthday"]];
//    }
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"relationship"]) {
//        [self.rowDataArray replaceObjectAtIndex:3 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"relationship"]];
//    }
//    
//    [self.tableView reloadData];
//    
//    // Set the name in the header view label
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"name"]) {
//        self.headerNameLabel.text = [[PFUser currentUser] objectForKey:@"profile"][@"name"];
//    }
//    
//    // Download the user's facebook profile picture
//    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
//    
//    if ([[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]) {
//        NSURL *pictureURL = [NSURL URLWithString:[[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]];
//        
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
//                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                              timeoutInterval:2.0f];
//        // Run network request asynchronously
//        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//        if (!urlConnection) {
//            NSLog(@"Failed to download picture");
//        }
//    }
}

@end
