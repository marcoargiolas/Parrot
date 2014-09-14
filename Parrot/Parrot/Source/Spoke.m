//
//  Spoke.m
//  Parrot
//
//  Created by Marco Argiolas on 03/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "Spoke.h"

@implementation Spoke

@synthesize spokeID;
@synthesize creationDate;
@synthesize updateDate;
@synthesize totalHeards;
@synthesize audioData;
@synthesize totalLikes;
@synthesize respokeToSpokeID;
@synthesize listOfHeardsID;
@synthesize ownerImageData;
@synthesize ownerName;
@synthesize ownerID;
@synthesize ownerSurname;
@synthesize listOfThankersID;
@synthesize listOfRespokeID;

- (id)init
{
	if (self = [super init])
	{
        spokeID = @"";
        creationDate = [[NSDate alloc]init];
        updateDate = [[NSDate alloc]init];
        totalLikes = 0;
        totalHeards = 0;
        audioData = [[NSData alloc]init];
        respokeToSpokeID = @"";
        listOfHeardsID = [[NSMutableArray alloc]init];
        listOfThankersID = [[NSMutableArray alloc]init];
        listOfRespokeID = [[NSMutableArray alloc]init];
        ownerSurname = @"";
        ownerName = @"";
        ownerID = @"";
        ownerImageData = [[NSData alloc]init];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:spokeID forKey:@"spokeID"];
    [aCoder encodeObject:creationDate forKey:@"creationDate"];
    [aCoder encodeObject:updateDate forKey:@"updateDate"];
    [aCoder encodeInt:totalLikes forKey:@"totalLikes"];
    [aCoder encodeInt:totalHeards forKey:@"totalHeards"];
    [aCoder encodeObject:audioData forKey:@"audioData"];
    [aCoder encodeObject:respokeToSpokeID forKey:@"respokeToSpokeID"];
    [aCoder encodeObject:listOfHeardsID forKey:@"listOfHeardsID"];
    [aCoder encodeObject:listOfThankersID forKey:@"listOfThankersID"];
    [aCoder encodeObject:listOfRespokeID forKey:@"listOfRespokeID"];
    [aCoder encodeObject:ownerImageData forKey:@"ownerImageData"];
    [aCoder encodeObject:ownerID forKey:@"ownerID"];
    [aCoder encodeObject:ownerName forKey:@"ownerName"];
    [aCoder encodeObject:ownerSurname forKey:@"ownerSurname"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        spokeID = [aDecoder decodeObjectForKey:@"spokeID"];
        creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        updateDate = [aDecoder decodeObjectForKey:@"updateDate"];
        totalLikes = [aDecoder decodeIntForKey:@"totalLikes"];
        totalHeards = [aDecoder decodeIntForKey:@"totalHeards"];
        audioData = [aDecoder decodeObjectForKey:@"audioData"];
        respokeToSpokeID = [aDecoder decodeObjectForKey:@"respokeToSpokeID"];
        listOfHeardsID = [aDecoder decodeObjectForKey:@"listOfHeardsID"];
        listOfThankersID = [aDecoder decodeObjectForKey:@"listOfThankersID"];
        listOfRespokeID = [aDecoder decodeObjectForKey:@"listOfRespokeID"];
        ownerImageData = [aDecoder decodeObjectForKey:@"ownerImageData"];
        ownerID = [aDecoder decodeObjectForKey:@"ownerID"];
        ownerName = [aDecoder decodeObjectForKey:@"ownerName"];
        ownerSurname = [aDecoder decodeObjectForKey:@"ownerSurname"];
    }
    
    return self;
}

@end
