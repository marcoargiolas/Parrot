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
	}
	return self;
}

@end
