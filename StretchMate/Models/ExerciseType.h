//
//  ExerciseType.h
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise;

@interface ExerciseType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *exercises;

+ (ExerciseType*)getExerciseTypeByName:(NSString*)typeName;

@end

@interface ExerciseType (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(Exercise *)value;
- (void)removeExercisesObject:(Exercise *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;

@end
