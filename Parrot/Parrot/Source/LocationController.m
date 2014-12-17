//
//  LocationController.m
//  Parrot
//
//  Created by Marco Argiolas on 04/10/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <CoreLocation/CLLocationManager.h>
#import "LocationController.h"

#define k_secondsToSendLocationToServer 60

static LocationController *shared = nil;


@implementation LocationController

#pragma mark -
#pragma mark Lifecycle methods
- (id)init
{
	if(self = [super init])
    {
		_locManager = [[CLLocationManager alloc] init];
		self.locManager.delegate = self;
		self.locManager.distanceFilter = 80;
		self.locManager.desiredAccuracy = kCLLocationAccuracyKilometer;

		_locationManagerUpdateStarted = NO;
        lastLocationSentDate = [NSDate date];
        position = nil;

        // Subscribe to application notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLocationUpdates) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLocationUpdates) name:UIApplicationDidFinishLaunchingNotification object:nil];
	}
    
	return self;	
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (LocationController*)sharedObject
{
	@synchronized([LocationController class])
    {
		if(!shared)
        {
			// allocate the shared instance, because it hasn't been done yet
			shared = [[self alloc] init];
		}
		return shared;
	}
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldlocation
{
    NSLog(@"locationManager didUpdateToLocation (%g %g)", newLocation.coordinate.latitude, newLocation.coordinate.longitude);

    NSTimeInterval locationAge = abs([newLocation.timestamp timeIntervalSinceDate:lastLocationSentDate]);
	//First update! Force it!
	if(position == nil || locationAge > k_secondsToSendLocationToServer)
    {
        lastLocationSentDate = newLocation.timestamp;

//        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive || [UIApplication sharedApplication].applicationState == UIApplicationStateInactive)
//        {
//            [srv sendUpdatedPosition:newLocation];
//        }
//        else
//        {
//            [self sendBackgroundLocationToServer:newLocation];
//        }
	}
    
    position = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status != kCLAuthorizationStatusAuthorized && status != kCLAuthorizationStatusNotDetermined) {
        [self stopLocationUpdates];
    }
    else {
        [self startLocationUpdates];
    }
}

#pragma mark -
#pragma mark Other delegate methods
- (void)positionSent
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    
    if(state != UIApplicationStateBackground)
    {
//        [srv getNearbyPeersWithPosition:position andPaging:@""];
//        BOOL pushen =  [ (iKiwiAppDelegate *)[[UIApplication sharedApplication] delegate] pushEnabled];
//        if(pushen == NO)
//        {
////            [srv updateNumberOfUnreadActivities];
//        }
    }
}

#pragma mark -
#pragma mark Selectors
- (void)startLocationUpdates
{
    BOOL locationEnabled = [CLLocationManager locationServicesEnabled];
    if([CLLocationManager respondsToSelector:@selector(authorizationStatus)])
    {
        CLAuthorizationStatus locationAuthorized = [CLLocationManager authorizationStatus];
        if(locationEnabled == NO || (locationAuthorized != kCLAuthorizationStatusAuthorized && locationAuthorized != kCLAuthorizationStatusNotDetermined) )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location", @"location alert") message:@"You must enable Location to use Parrot" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
    }
    
    if (_locationManagerUpdateStarted) {
        return;
    }
    
    [_locManager startMonitoringSignificantLocationChanges];
    _locationManagerUpdateStarted = YES;
}

- (void)stopLocationUpdates
{
    if (!_locationManagerUpdateStarted) {
        return;
    }
    
    [_locManager stopMonitoringSignificantLocationChanges];
    _locationManagerUpdateStarted = NO;
}

#pragma mark -
#pragma mark Utility methods
- (void)sendBackgroundLocationToServer:(CLLocation *)location
{
    bgTask = [[UIApplication sharedApplication]
              beginBackgroundTaskWithExpirationHandler:
              ^{
                  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
              }];
    
//    [srv sendPositionInBackground:location];
    
    if (bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
}

- (void)sendPositionForced
{
//    [srv sendUpdatedPosition:position];
}

- (void)DEBUG_OpenLocation
{
    NSString *url = [[NSString alloc] initWithFormat:@"http://maps.google.com/?q=%f%%20%f", position.coordinate.latitude, position.coordinate.longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
