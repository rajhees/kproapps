//
//  SavedExercise.h
//  StretchMate
//
//  Created by James Eunson on 29/11/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Exercise.h"

@interface SavedExercise : NSManagedObject

@property (nonatomic, retain) NSNumber * exerciseIdentifier;
@property (nonatomic, retain) NSDate * date;

+ (void)createSavedExerciseWithExercise:(Exercise*)exercise;
- (Exercise*)exercise;

@end
