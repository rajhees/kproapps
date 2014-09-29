//
//  SavedExercise.m
//  StretchMate
//
//  Created by James Eunson on 29/11/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "SavedExercise.h"
#import "AppDelegate.h"

@interface SavedExercise()

// Shortcut functions
+ (NSManagedObjectContext*)context;
+ (NSManagedObjectContext*)userContext;
@end

@implementation SavedExercise

@dynamic exerciseIdentifier;
@dynamic date;

+ (NSManagedObjectContext*)userContext { return [(AppDelegate*)[[UIApplication sharedApplication] delegate] userManagedObjectContext]; }
+ (NSManagedObjectContext*)context { return [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]; }

+ (void)createSavedExerciseWithExercise:(Exercise*)exercise {
    
    SavedExercise * item = (SavedExercise*)[NSEntityDescription insertNewObjectForEntityForName:@"SavedExercise" inManagedObjectContext:self.userContext];
    item.date = [NSDate date];
    item.exerciseIdentifier = exercise.identifier;
    
    NSError * error = nil;
    BOOL success = [self.userContext save:&error];
    
//    if(success) {
//        [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"tick"] withLabelText:[NSString stringWithFormat:@"%@ Added", self.name] withDetailsLabelText:@"Shopping List Updated"];
//    } else {
//        [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"cross"] withLabelText:@"Food Not Added" withDetailsLabelText:@"Please try again later"];
//        NSLog(@"addFoodToShoppingList: Error: %@", [error localizedDescription]);
//    }
    
    if(success) {
//        NSLog(@"createSavedExerciseWithExercise: success");
    } else {
//        NSLog(@"createSavedExerciseWithExercise: Error: %@", [error localizedDescription]);
    }
}

- (Exercise*)exercise {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", self.exerciseIdentifier];
    
    NSError * error = nil;
    NSArray * results = [[self class].context executeFetchRequest:fetchRequest error:&error];
    return [results firstObject];
}

@end
