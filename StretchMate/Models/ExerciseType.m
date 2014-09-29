//
//  ExerciseType.m
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseType.h"
#import "Exercise.h"
#import "AppDelegate.h"

@implementation ExerciseType

@dynamic name;
@dynamic exercises;

+ (ExerciseType*)getExerciseTypeByName:(NSString*)typeName {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * context = [delegate managedObjectContext];
    
    NSError * error = nil;
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ExerciseType"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", typeName]];
    NSArray * results = [context executeFetchRequest:fetchRequest error:&error];
    
    if([results count] == 0 || !results) return nil;
    
    if([results count] != 1) {
//        NSLog(@"More than one type returned for query that should only return one type.");
        return nil;
    }
    
    ExerciseType * type = (ExerciseType*)[results lastObject];
    return type;
}

@end
