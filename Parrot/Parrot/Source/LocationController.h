//
//  LocationController.h
//  Parrot
//
//  Created by Marco Argiolas on 04/10/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationController : NSObject <CLLocationManagerDelegate>
{
    CLLocation *position;
    NSDate *lastLocationSentDate;

    UIBackgroundTaskIdentifier bgTask;
}


@property (strong, readonly) CLLocationManager *locManager;
@property (assign, readonly) BOOL locationManagerUpdateStarted;


+ (id)sharedObject;

- (void)sendPositionForced;
- (void)DEBUG_OpenLocation;

@end
