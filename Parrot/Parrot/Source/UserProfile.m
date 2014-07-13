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
        currentUser = [[PFUser alloc]init];
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
            
            if (facebookID) {
                currentProfile[USER_ID] = facebookID;
            }
            
            if (userData[@"name"]) {
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
            
            if (userData[@"bio"])
            {
                currentProfile[USER_BIO] = userData[@"bio"];
            }
            
            if ([pictureURL absoluteString])
            {
                NSURL *imageUrl = [NSURL URLWithString:[pictureURL absoluteString]];
                NSData *imageData = [[NSData alloc]initWithContentsOfURL:imageUrl];
                
                currentProfile[USER_IMAGE_DATA] = imageData;
            }
            
            [currentUser setObject:currentProfile forKey:USER_PROFILE];
            [currentUser setObject:spokesArray forKey:USER_SPOKES_ARRAY];
            
//            [currentUser saveInBackground];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:PROFILE_LOADED_FROM_FACEBOOK object:nil];
            [[NSUserDefaults standardUserDefaults] setObject:facebookID forKey:USER_ID];
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
    return [NSString stringWithFormat:@"%@",[[currentUser objectForKey:USER_PROFILE] objectForKey:USER_ID]];
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
    [obj setObject:spokeToSave.audioData forKey:@"audioData"];
    [obj setObject:[NSString stringWithFormat:@"%d",spokeToSave.totalLikes] forKey:@"totalLikes"];
    [obj setObject:spokeToSave.respokeToSpokeID forKey:@"respokeToSpokeID"];
    [obj setObject:spokeToSave.ownerID forKey:@"ownerID"];
    
    [obj saveInBackground];
    
//    [self loadSpokesFromRemoteForUser:[[currentUser objectForKey:@"profile"] objectForKey:@"userID"]];
}

//-(void)updateTotalSpokeLike:(NSString*)spokeID
//{
//    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
//    [query whereKey:<#(NSString *)#> equalTo:<#(id)#>];
//    [query getObjectInBackgroundWithId:spokeID block:^(PFObject *spokeObj, NSError *error) {
//        Spoke *tempObj = (Spoke*)spokeObj;//[self getSpokeWithID:spokeID];
//        [spokeObj setObject:[NSString stringWithFormat:@"%d",tempObj.totalLikes] forKey:@"totalLikes"];
//        [spokeObj saveInBackground];
//    }];
//}

-(void)loadSpokesFromRemoteForUser:(NSString*)userID
{
    PFQuery *query = [PFQuery queryWithClassName:@"spoke"];
    [query whereKey:@"ownerID" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
        } else {
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
//- (void)updateProfile {
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
//}

@end
