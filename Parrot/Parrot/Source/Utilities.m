//
//  Utilities.m
//  Parrot
//
//  Created by Marco Argiolas on 05/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "Utilities.h"
#import "EZAudio.h"

@implementation Utilities

static NSString *currentSpokeID = nil;
#pragma mark - Utility
+(NSArray*)applicationDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

+(NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+(NSURL*)soundFilePathUrl
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMddyyyyHHmmss:SSS"];
    NSDate *now = [[NSDate alloc] init];
    currentSpokeID = [format stringFromDate:now];
    currentSpokeID = [currentSpokeID stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *spokeFileName = [NSString stringWithFormat:@"%@.m4a", currentSpokeID];
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory],
                                   spokeFileName]];
}


+(NSString*)soundFilePathString
{
    NSString *returnID = currentSpokeID;
    currentSpokeID = nil;
    return returnID;
}

@end
