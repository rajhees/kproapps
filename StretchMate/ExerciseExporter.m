//
//  ExerciseExporter.m
//  Exersite
//
//  Created by James Eunson on 3/07/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseExporter.h"
#import "AppDelegate.h"
#import "Exercise.h"
#import "ExerciseType.h"
#import "NSArray+FirstObject.h"

#define kExercisesCSVFilename @"ExersiteExercises.csv"
#define kExercisesTypeCSVFilename @"ExersiteExerciseTypes.csv"
#define kExerciseExercisesTypesCSVFilename @"ExersiteExerciseExercisesTypes.csv"

@interface ExerciseExporter ()

@property (nonatomic, strong) NSManagedObjectContext * context;

- (void)exportExercises;
- (NSDictionary*)exportTypes;
- (void)exportExercisesTypesWithTypes:(NSDictionary*)typesDict;

@end

@implementation ExerciseExporter

- (void)startExportWithCompletion:(void (^)(BOOL success))completionHandler {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.context = [delegate managedObjectContext];
    
    [self exportExercises];
    NSDictionary * typesDict = [self exportTypes];
    [self exportExercisesTypesWithTypes:typesDict];
    
    completionHandler(YES);
}

- (void)exportExercises {
    
    NSFetchRequest * allExercisesFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSMutableString * exercisesCSVFileContentsString = [[NSMutableString alloc] init];
    
    NSError * error = nil;
    NSArray * results = [self.context executeFetchRequest:allExercisesFetchRequest error:&error];
    
    // Add fields line
    NSString * fieldsLine = @"id,level,location,seconds,equipment,image,namebasic,nametechnical,number,purpose,instructions,related\n";
    [exercisesCSVFileContentsString appendString:fieldsLine];
    
    for(Exercise * exercise in results) {
        
        // Create instructions string
        NSArray * exerciseInstructions = (NSArray*)exercise.instructions;
        NSString * concatInstructions = [NSString stringWithFormat:@"%@", [exerciseInstructions componentsJoinedByString:@", "]];
        
        // Create related exercises string
        NSArray * relatedExercises = exercise.relatedExercises;
        NSMutableArray * relatedExercisesNumbersStrings = [@[] mutableCopy];
        for(Exercise * relatedExercise in relatedExercises) {
            [relatedExercisesNumbersStrings addObject:[NSString stringWithFormat:@"%@, ", relatedExercise.number]];
        }
        
        // Retrieve and clean related exercises data
        NSString * relatedExercisesString = nil;
        if([relatedExercisesNumbersStrings count] > 0) {
            
            NSMutableArray * cleanedRelatedExercisesNumbersStrings = [@[] mutableCopy];
            for(NSString * relatedExerciseNumbersString in relatedExercisesNumbersStrings) {
                
                // Remove all characters that aren't a-zA-Z0-9
                NSString * cleanedString = [[relatedExerciseNumbersString componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
                [cleanedRelatedExercisesNumbersStrings addObject:cleanedString];
            }
            
            relatedExercisesString = [cleanedRelatedExercisesNumbersStrings componentsJoinedByString:@","];
        } else {
            relatedExercisesString = @"(null)";
        }
        
        // Create equipment string
        NSArray * exerciseEquipmentArray = [exercise getEquipment];
        NSString * exerciseEquipmentString = [exerciseEquipmentArray componentsJoinedByString:@", "];
        
        // Created final formatted string for inclusion in CSV
        NSString * formattedStringForLine = [NSString stringWithFormat:@"%@,%@,%@,%@,\"%@\",%@,\"%@\",\"%@\",%@,\"%@\",\"%@\",\"%@\"\n", exercise.identifier, exercise.level, exercise.location, exercise.seconds, exerciseEquipmentString, exercise.image, exercise.nameBasic, exercise.nameTechnical, exercise.number, exercise.purpose, concatInstructions, relatedExercisesString];
        
        if([formattedStringForLine rangeOfString:@"(null)"].location != NSNotFound) {
            formattedStringForLine = [formattedStringForLine stringByReplacingOccurrencesOfString:@"\"(null)\"" withString:@"NULL"];
            formattedStringForLine = [formattedStringForLine stringByReplacingOccurrencesOfString:@"(null)" withString:@"NULL"];
        }
        
        [exercisesCSVFileContentsString appendString:formattedStringForLine];
    }
    
    NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * exercisesCSVURL = [applicationDocumentsDirectory URLByAppendingPathComponent:kExercisesCSVFilename];
    
    [exercisesCSVFileContentsString writeToFile:[exercisesCSVURL path] atomically:YES encoding:NSUTF8StringEncoding error:&error];
}
- (NSDictionary*)exportTypes {
    
    // Export exercise types
    NSMutableDictionary * typesDict = [@{} mutableCopy]; // Reference dict for exportExercisesTypesWithTypes method
    
    NSFetchRequest * typesFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ExerciseType"];
    NSMutableString * typesCSVFileContentsString = [[NSMutableString alloc] init];
    
    NSError * error = nil;
    NSArray * results = [self.context executeFetchRequest:typesFetchRequest error:&error];
    
    NSString * fields = @"id,name\n";
    [typesCSVFileContentsString appendString:fields];
    
    NSInteger i = 1;
    for(ExerciseType * type in results) {
        [typesCSVFileContentsString appendFormat:@"%d,%@\n", i, type.name];
        typesDict[@(i)] = type;
    
        i++;
    }
    
    NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * typesCSVURL = [applicationDocumentsDirectory URLByAppendingPathComponent:kExercisesTypeCSVFilename];
    
    [typesCSVFileContentsString writeToFile:[typesCSVURL path] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    return typesDict;
}

- (void)exportExercisesTypesWithTypes:(NSDictionary*)typesDict {
    
    // Duplicate request, doesn't matter
    NSFetchRequest * allExercisesFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];    
    NSMutableString * exercisesTypesRelationsCSVString = [[NSMutableString alloc] init];
    
    NSError * error = nil;
    NSArray * results = [self.context executeFetchRequest:allExercisesFetchRequest error:&error];
    
    NSString * fields = @"id,exercise_id,exercise_type_id\n";
    [exercisesTypesRelationsCSVString appendString:fields];    
    
    NSInteger i = 0;
    for(Exercise * exercise in results) {
        
        NSArray * types = [exercise.types allObjects];
        for(ExerciseType * type in types) {
            
            NSArray * keysForObject = [typesDict allKeysForObject:type];
//            if(!keysForObject || [keysForObject count] == 0) {
//                NSLog(@"Problem");
//            }
            
            NSNumber * numberKeyForObject = [keysForObject firstObject];
            NSString * formattedStringForLine = [NSString stringWithFormat:@"%d,%@,%@\n", i, exercise.identifier, numberKeyForObject];
            
            [exercisesTypesRelationsCSVString appendString:formattedStringForLine];
        }
        
        i++;
    }
    
    NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * exercisesTypesRelationsCSVURL = [applicationDocumentsDirectory URLByAppendingPathComponent:kExerciseExercisesTypesCSVFilename];
    
    [exercisesTypesRelationsCSVString writeToFile:[exercisesTypesRelationsCSVURL path] atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end
