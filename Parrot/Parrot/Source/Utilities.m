//
//  Utilities.m
//  Parrot
//
//  Created by Marco Argiolas on 05/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import "Utilities.h"
#import "EZAudio.h"
#import "Spoke.h"

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

+(NSMutableArray*)orderByDate:(NSMutableArray*)spokesArray
{
    NSSortDescriptor * dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    
    NSArray * descriptors = [NSArray arrayWithObjects:dateDescriptor, nil];
    NSArray * sortedArray = [spokesArray sortedArrayUsingDescriptors:descriptors];
    return [NSMutableArray arrayWithArray:sortedArray];
}

+ (NSString*)getDateString:(NSDate*) date WithFormat:(NSDateFormatter*)dateFormatter
{
    NSString *dateString;
    NSTimeInterval outdate = [date timeIntervalSinceDate:[NSDate date]];
    int seconds = (int)fabs(outdate);
    int minutes = seconds/60;
    int hours = minutes/60;
    int days = hours/24;
    
    seconds = seconds % 60;
    minutes = minutes % 60;
    hours = hours % 24;
    
    if(days!=0)
    {
        if(days<7)
        {
            if(hours>=12) days++;
            if(days==1)
                dateString = [NSString stringWithFormat:NSLocalizedString(@"%d day ago", @""), days];
            else
                dateString = [NSString stringWithFormat:NSLocalizedString(@"%d days ago", @""), days];
        }
        else
        {
            dateString = [dateFormatter stringFromDate:date];
        }
    }
    else if(hours!=0)
    {
        if(minutes>=30) hours++;
        if(hours==1)
            dateString = [NSString stringWithFormat:NSLocalizedString(@"%d hour ago", @""), hours];
        else
            dateString = [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", @""), hours];
    }
    else if(minutes!=0)
    {
        if(minutes==1)
            dateString = [NSString stringWithFormat:NSLocalizedString(@"%d min ago", @""), minutes];
        else
            dateString = [NSString stringWithFormat:NSLocalizedString(@"%d min ago", @""), minutes];
    }
    else
    {
        if(seconds==1)
            dateString = [NSString stringWithFormat:NSLocalizedString(@"%d sec ago", @""), seconds];
        else
            dateString = [NSString stringWithFormat:NSLocalizedString(@"%d sec ago", @""), seconds];
    }
    return dateString;
}

@end
