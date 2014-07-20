//
//  Utilities.h
//  Parrot
//
//  Created by Marco Argiolas on 05/07/14.
//  Copyright (c) 2014 Marco Argiolas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAudio.h"

@interface Utilities : NSObject

+(NSArray*)applicationDocuments;
+(NSString*)applicationDocumentsDirectory;
+(NSURL*)soundFilePathUrl;
+(NSString*)soundFilePathString;
+(NSMutableArray*)orderByDate:(NSMutableArray*)spokesArray;
+ (NSString*)getDateString:(NSDate*) date WithFormat:(NSDateFormatter*)dateFormatter;

@end
