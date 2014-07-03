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
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [paths objectAtIndex:0];
//	NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"profile.plist"];
//	if([[NSFileManager defaultManager] fileExistsAtPath:finalPath])
//    {
//		[[NSFileManager defaultManager] removeItemAtPath:finalPath error:nil];
//	}
//    
//    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:USERID];
//    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:userID];
//    finalPath = [documentsDirectory stringByAppendingPathComponent:@"profile.plist"];
//	if(![[NSFileManager defaultManager] fileExistsAtPath:finalPath])
//    {
//		NSString *path = [[NSBundle mainBundle] bundlePath];
//		finalPath = [path stringByAppendingPathComponent:@"profile.plist"];
//	}
//    
//	userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:finalPath];
}

- (void)saveProfileLocal
{
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//	NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:[self getUserID]];
//	NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"profile.plist"];
//    
//    if(![[NSFileManager defaultManager] fileExistsAtPath:finalPath])
//    {
//        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory
//                                  withIntermediateDirectories:YES
//                                                   attributes:nil
//                                                        error:nil];
//    }
//    if(userInfo != nil)
//        [userInfo writeToFile:finalPath atomically:NO];
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
            
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] init];
            
            if (facebookID) {
                userProfile[USER_ID] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[USER_FULL_NAME] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[USER_LOCATION] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[USER_GENDER] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[USER_BIRTHDAY] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                userProfile[USER_RELATIONSHIP] = userData[@"relationship_status"];
            }
            
            if (userData[@"bio"])
            {
                userProfile[USER_BIO] = userData[@"bio"];
            }
            
            if ([pictureURL absoluteString])
            {
                NSURL *imageUrl = [NSURL URLWithString:[pictureURL absoluteString]];
                NSData *imageData = [[NSData alloc]initWithContentsOfURL:imageUrl];
                
                userProfile[USER_IMAGE_DATA] = imageData;
            }
            
            [currentUser setObject:userProfile forKey:USER_PROFILE];
//            [currentUser saveInBackground];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:PROFILE_LOADED_FROM_FACEBOOK object:nil];
//            [self updateProfile];
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
