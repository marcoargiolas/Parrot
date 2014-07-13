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
@synthesize totalHeards;
@synthesize audioData;
@synthesize totalLikes;
@synthesize respokeToSpokeID;
@synthesize listOfHeardsID;

- (id)init
{
	if (self = [super init])
	{
        spokeID = @"";
        creationDate = [[NSDate alloc]init];
        totalLikes = 0;
        totalHeards = 0;
        audioData = [[NSData alloc]init];
        respokeToSpokeID = @"";
        listOfHeardsID = [[NSMutableArray alloc]init];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:spokeID forKey:@"spokeID"];
    [aCoder encodeObject:creationDate forKey:@"creationDate"];
    [aCoder encodeInt:totalLikes forKey:@"totalLikes"];
    [aCoder encodeInt:totalHeards forKey:@"totalHeards"];
    [aCoder encodeObject:audioData forKey:@"audioData"];
    [aCoder encodeObject:respokeToSpokeID forKey:@"respokeToSpokeID"];
    [aCoder encodeObject:listOfHeardsID forKey:@"listOfHeardsID"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        spokeID = [aDecoder decodeObjectForKey:@"spokeID"];
        creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        totalLikes = [aDecoder decodeIntForKey:@"totalLikes"];
        totalHeards = [aDecoder decodeIntForKey:@"totalHeards"];
        audioData = [aDecoder decodeObjectForKey:@"audioData"];
        respokeToSpokeID = [aDecoder decodeObjectForKey:@"respokeToSpokeID"];
        listOfHeardsID = [aDecoder decodeObjectForKey:@"listOfHeardsID"];
    }
    
    return self;
}

@end
