//
//  Program.m
//  StretchMate
//
//  Created by James Eunson on 12/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "Program.h"
#import "Exercise.h"
#import "ProgramItemCell.h"
#import "AppDelegate.h"
#import "NSString+MD5Hash.h"
#import "EGOCache.h"

@interface Program ()

@end

@implementation Program

@dynamic title;
@dynamic identifier;
@dynamic programDescription;
@dynamic exercises;

@synthesize timeslots = _timeslots;

+ (Program*)programForIdentifier:(NSNumber*)identifier {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Program"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    
    NSError * error = nil;
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    NSArray * results = [context executeFetchRequest:fetchRequest error:&error];
    
    if(!results || [results count] == 0) {
        return nil;
    }
    return [results firstObject];
}

- (NSString*)getExerciseString {
    
    if(self.exercises.count > 1 || self.exercises.count == 0) {
        return [NSString stringWithFormat:@"%d Exercises", self.exercises.count];
    } else {
        return [NSString stringWithFormat:@"%d Exercise", self.exercises.count];
    }
}

- (UIImage*)getOverviewImageWithSize:(CGSize)sizeForOverviewImage type:(OverviewImageType)type {
    
    NSString * cacheKey = [NSString stringWithFormat:@"%@-%d-%d", [self.title MD5Hash], ((int)sizeForOverviewImage.width), ((int)sizeForOverviewImage.height)];
    if([[EGOCache globalCache] hasCacheForKey:cacheKey]) {
        UIImage * cachedOverviewImage = [UIImage imageWithData:[[EGOCache globalCache] dataForKey:cacheKey]];
        return cachedOverviewImage;
    }
    
    UIView * overviewImageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sizeForOverviewImage.width, sizeForOverviewImage.height)];
    overviewImageContainerView.backgroundColor = [UIColor whiteColor];
    overviewImageContainerView.layer.cornerRadius = 4.0f;
    overviewImageContainerView.layer.masksToBounds = YES;
    
    int i = 0, limit = 4;
    
    if(self.exercises.count == 1) {
        limit = 1;
    } else if(sizeForOverviewImage.height < 60 || self.exercises.count == 2) {
        limit = 2;   
    }
    
    for(Exercise * exercise in self.exercises) {
        
        NSArray * exerciseImages = [exercise getImages];
        UIImage * exerciseOverviewImage = [exerciseImages firstObject];
        if(!exerciseOverviewImage) {
            continue;
        }
        
        UIImageView * exerciseOverviewImageView = [[UIImageView alloc] initWithImage:exerciseOverviewImage];
        exerciseOverviewImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGFloat xOffset = 0;
        CGFloat yOffset = 0;
        
        if(limit == 4) {
            
            if(i == 1) {
                xOffset = sizeForOverviewImage.width/2; yOffset = 0;
            } else if(i == 2) {
                xOffset = 0; yOffset = sizeForOverviewImage.height/2;
            } else if(i == 3) {
                xOffset = sizeForOverviewImage.width/2; yOffset = sizeForOverviewImage.height/2;
            }
            
            exerciseOverviewImageView.frame = CGRectMake(xOffset, yOffset, sizeForOverviewImage.width/2, sizeForOverviewImage.height/2);
            
        } else if(limit == 2) {
            
            if(i == 1) {
                xOffset = sizeForOverviewImage.width/2; yOffset = 0;
            }
            exerciseOverviewImageView.frame = CGRectMake(xOffset, yOffset, sizeForOverviewImage.width/2, sizeForOverviewImage.height);
            
        } else {
            exerciseOverviewImageView.frame = CGRectMake(xOffset, yOffset, sizeForOverviewImage.width, sizeForOverviewImage.height);
        }
        
        
        [overviewImageContainerView addSubview:exerciseOverviewImageView];
        
        if(i == (limit - 1)) break;
        
        i++;
    }

    UIGraphicsBeginImageContextWithOptions(overviewImageContainerView.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [overviewImageContainerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *overviewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTimeInterval thirtyDaysTimeInterval = (60 * 60 * 24 * 30);
    NSData *imageData = UIImageJPEGRepresentation(overviewImage, 100);
    [[EGOCache globalCache] setData:imageData forKey:cacheKey withTimeoutInterval:thirtyDaysTimeInterval];
    
//    NSLog(@"cache complete");
    
    return overviewImage;
}

- (NSInteger)completionTimeInMinutes {
    
    NSArray * programExercises = [self.exercises allObjects];
    
    double programCompletionSeconds = 0;
    double programCompletionMinutes = 0;
    for(Exercise * programExercise in programExercises) {
        programCompletionSeconds += ((double)[programExercise.seconds intValue]);
    }
    programCompletionMinutes = (programCompletionSeconds / 60);
    
    NSInteger roundedCompletionMinutes = (int)round(programCompletionMinutes);
    
    return roundedCompletionMinutes;
}

- (NSString*)getCompletionTimeString {
    
    NSInteger completionTime = [self completionTimeInMinutes];
    
    if(completionTime == 1) {
        return [NSString stringWithFormat:@"Min completion Time: %d min", completionTime];
    } else {
        return [NSString stringWithFormat:@"Min completion Time: %d mins", completionTime];
    }
}

- (NSString*)getShortCompletionTimeString {
    
    NSInteger completionTime = [self completionTimeInMinutes];
    return [NSString stringWithFormat:@"%dm", completionTime];
}

@end
