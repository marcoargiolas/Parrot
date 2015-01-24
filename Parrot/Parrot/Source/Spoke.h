//
//  Spoke.h
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Spoke : NSObject
{
    NSString *spokeID;
    NSData *audioData;
    NSDate *creationDate;
    NSDate *updateDate;
    int totalLikes;
    int totalHeards;
    NSString *respokeToSpokeID;
    NSString *ownerID;
    NSString *ownerName;
    NSString *ownerSurname;
    NSData *ownerImageData;
    NSData *spokePositionImageData;
    NSData *spokeImageData;
    NSMutableArray *listOfHeardsID;
    NSMutableArray *listOfThankersID;
    NSMutableArray *listOfRespokeID;
    CLLocation *spokeLocation;
    NSString *spokeText;
    NSString *spokeAddress;
}
@property (nonatomic, strong) NSString *spokeAddress;
@property (nonatomic, strong) NSString *spokeText;
@property (nonatomic, strong) CLLocation *spokeLocation;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *ownerSurname;
@property (nonatomic, strong) NSData *ownerImageData;
@property (nonatomic, strong) NSData *spokeImageData;
@property (nonatomic, strong) NSData *spokePositionImageData;
@property (nonatomic, strong) NSMutableArray *listOfHeardsID;
@property (nonatomic, strong) NSMutableArray *listOfThankersID;
@property (nonatomic, strong) NSMutableArray *listOfRespokeID;
@property (nonatomic, strong) NSString *ownerID;
@property (nonatomic, strong) NSString *spokeID;
@property (nonatomic, strong) NSData *audioData;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *updateDate;
@property (nonatomic, assign) int totalLikes;
@property (nonatomic, assign) int totalHeards;
@property (nonatomic, strong) NSString *respokeToSpokeID;

@end
