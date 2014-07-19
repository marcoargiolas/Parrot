//
//  Spoke.h
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Spoke : NSObject
{
    NSString *spokeID;
    NSData *audioData;
    NSDate *creationDate;
    int totalLikes;
    int totalHeards;
    NSString *respokeToSpokeID;
    NSString *ownerID;
    NSString *ownerName;
    NSString *ownerSurname;
    NSData *ownerImageData;
    NSMutableArray *listOfHeardsID;
}

@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *ownerSurname;
@property (nonatomic, strong) NSData *ownerImageData;
@property (nonatomic, strong) NSMutableArray *listOfHeardsID;
@property (nonatomic, strong) NSString *ownerID;
@property (nonatomic, strong) NSString *spokeID;
@property (nonatomic, strong) NSData *audioData;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, assign) int totalLikes;
@property (nonatomic, assign) int totalHeards;
@property (nonatomic, strong) NSString *respokeToSpokeID;

@end
