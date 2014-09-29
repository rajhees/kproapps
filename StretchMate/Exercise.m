//
//  Exercise.m
//  Exersite
//
//  Created by James Eunson on 27/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "Exercise.h"
#import "Exercise.h"
#import "ExerciseType.h"
#import "Program.h"
#import "AppDelegate.h"
#import "SavedExercise.h"
#import "NSArray+FirstObject.h"
#import "RegexKitLite.h"

@interface Exercise()

// Shortcut functions
+ (NSManagedObjectContext*)context;
+ (NSManagedObjectContext*)userContext;
- (SavedExercise*)savedExercise;
@end

@implementation Exercise

@synthesize tempProcessedInstructionsList;
@synthesize canonical = _canonical;
@synthesize canonicalExercise = _canonicalExercise;
@synthesize canonicalNameTechnical = _canonicalNameTechnical;
@synthesize canonicalNameBasic = _canonicalNameBasic;
@synthesize canonicalNumber = _canonicalNumber;
@synthesize relatedExercises = _relatedExercises;
@synthesize completed = _completed;

@dynamic equipment;
@dynamic identifier;
@dynamic image;
@dynamic instructions;
@dynamic level;
@dynamic location;
@dynamic nameBasic;
@dynamic nameTechnical;
@dynamic number;
@dynamic purpose;
@dynamic seconds;
@dynamic programs;
@dynamic types;
@dynamic related;

+ (NSManagedObjectContext*)userContext { return [(AppDelegate*)[[UIApplication sharedApplication] delegate] userManagedObjectContext]; }
+ (NSManagedObjectContext*)context { return [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]; }

+ (NSNumber*)getTypeForLocationString:(NSString*)locationString {
    
    // Straight linear search of lookup dictionary
    NSArray * keys = [kExerciseLocationLookupHash allKeys];
    NSNumber * found = nil;
    for(NSString * key in keys) {
        if([key rangeOfString:locationString].location != NSNotFound) {
            found = kExerciseLocationLookupHash[key];
            break;
        }
    }
    
    return found;
}

+ (NSString*)getLocationStringForType:(NSNumber*)type {
    
    NSArray * keys = [kExerciseLocationLookupHash allValues];
    for(NSString * key in keys) {
        if([kExerciseLocationLookupHash[key] isEqual:type]) {
            return key;
        }
    }
    return nil;
}

+ (NSArray*)sortedExerciseLocations {
    return [[kExerciseLocationLookupHash allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString*)locationString {
    return [[self class] getLocationStringForType:self.location];
}

// Retrieves a concat string of types for display in the exercises index
- (NSString*)typesString {
    NSArray * typesArray = [self.types allObjects];
    NSMutableArray * typesStringArray = [[NSMutableArray alloc] init];
    
    for(ExerciseType * type in typesArray) {
        [typesStringArray addObject:type.name];
    }
    
    return [typesStringArray componentsJoinedByString:@", "];
}

- (NSArray*)getInstructionList {
    
    NSArray * rawInstructions = (NSArray*)self.instructions;
    if(!rawInstructions || [rawInstructions count] == 0) return nil;
    
    if(self.tempProcessedInstructionsList) {
        return self.tempProcessedInstructionsList;
    }
    
    NSMutableArray * processedInstructions = [[NSMutableArray alloc] init];
    for(NSString * instructionString in rawInstructions) {
        
        if([instructionString rangeOfString:@")"].location != NSNotFound) { // Numbered instruction
            
            @try {
                
                NSString * bracketAndNumber = [instructionString stringByMatching:@"^[0-9]+([ ]?)\\)"];
                NSString * instructionNumber = bracketAndNumber;
                if(instructionNumber) {
                    instructionNumber = [[bracketAndNumber stringByReplacingOccurrencesOfString:@")" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                
                if(!instructionNumber) {
//                    NSLog(@"ERROR: Unable to parse instruction string: %@", instructionString);
                    continue;
                }
                
                NSString * cleanedInstructionString = [[instructionString stringByReplacingOccurrencesOfString:bracketAndNumber withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSDictionary * instructionDict = @{@"number" : instructionNumber, @"instruction": cleanedInstructionString };
                [processedInstructions addObject:instructionDict];
            }
            @catch (NSException *exception) {
                
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred while preparing instructions for this exercise." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            //            NSLog(@"numbered instruction: %@", instructionString);
        }
        //        } else { // Non-numbered instruction
        //            NSLog(@"non numbered instruction: %@", instructionString);
        //        }
    }
    
    self.tempProcessedInstructionsList = processedInstructions;
    
    return self.tempProcessedInstructionsList;
}

- (BOOL)isExerciseSaved {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SavedExercise"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"exerciseIdentifier == %@", self.identifier];
    
    NSError * error = nil;
    NSArray * results = [[self class].userContext executeFetchRequest:fetchRequest error:&error];
    if(!results || error) return NO;
    
    return (results.count > 0);
}

- (BOOL)isExercisePrescribed {
    // @TODO
    return NO;
}

- (void)toggleExerciseSaved {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SavedExercise"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"exerciseIdentifier == %@", self.identifier];
    
    NSError * error = nil;
    NSArray * results = [[self class].userContext executeFetchRequest:fetchRequest error:&error];
    if(!results || error) return;
    
    SavedExercise * savedExercise = nil;
    savedExercise = [results firstObject];
    
    if(savedExercise) { // Delete
        
        [[self class].userContext deleteObject:savedExercise];
        [[self class].userContext save:&error];
        
    } else { // Create new exercise
        
        [SavedExercise createSavedExerciseWithExercise:self];
    }
}

- (NSArray*)getImages {
    
    NSMutableArray * images = [[NSMutableArray alloc] init];
    NSString * uppercaseImageNumber = [[self image] uppercaseString];
    
    // Establish if first image exists
//    NSLog(@"image: %@", [NSString stringWithFormat:@"%@.jpg", uppercaseImageNumber]);
    UIImage * firstImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", uppercaseImageNumber]];
    if(firstImage != nil) {
        [images addObject:firstImage];
    }
    
    // Determine if subsequent images exist
    int i = 1;
    while(true) {
        
//        NSLog(@"image: %@", [NSString stringWithFormat:@"%@-%d.jpg", uppercaseImageNumber, i]);
        UIImage * subsequentImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%d.jpg", uppercaseImageNumber, i]];
        if(subsequentImage != nil) {
            [images addObject:subsequentImage];
        } else {
            break;
        }
        i++;
    }
    return images;
}

- (NSArray*)getImagePaths {
    
    NSMutableArray * imagePaths = [[NSMutableArray alloc] init];
    NSString * uppercaseImageNumber = [[self image] uppercaseString];
    
    // Establish if first image exists
    UIImage * firstImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", uppercaseImageNumber]];
    if(firstImage != nil) {
        [imagePaths addObject:[NSString stringWithFormat:@"%@.jpg", uppercaseImageNumber]];
    }
    
    // Determine if subsequent images exist
    int i = 1;
    while(true) {
        
        UIImage * subsequentImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%d.jpg", uppercaseImageNumber, i]];
        if(subsequentImage != nil) {
            [imagePaths addObject:[NSString stringWithFormat:@"%@-%d.jpg", uppercaseImageNumber, i]];
        } else {
            break;
        }
        i++;
    }
    
    return imagePaths;
    
}

- (NSArray*)getEquipment {
    
    if(![self equipment] || [[self equipment] length] == 0 || [[[self equipment] lowercaseString] isEqualToString:@"nil"]) return nil;
    
    NSString * splitCharacter = nil;
    
    // This can be fixed with preprocessing, for now, do it in code
    if([[self equipment] rangeOfString:@"/"].location != NSNotFound) {
        splitCharacter = @"/";
    } else {
        splitCharacter = @",";
    }
    
    NSArray * rawEquipmentStrings = [[self equipment] componentsSeparatedByString:splitCharacter];
    NSMutableArray * cleanedEquipmentStrings = [[NSMutableArray alloc] init];
    
    for(NSString * rawEquipmentString in rawEquipmentStrings) {
        
        NSString * cleanedString = [rawEquipmentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cleanedString = [NSString stringWithFormat:@"%@%@", [[cleanedString substringToIndex:1] capitalizedString], [cleanedString substringFromIndex:1]];
        [cleanedEquipmentStrings addObject:cleanedString];
    }
    return cleanedEquipmentStrings;
}

- (UIImage*)getThumbnailImage {
    
    NSString * uppercaseImageNumber = [[self image] uppercaseString];
    UIImage * thumbnailImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-thumb.jpg", uppercaseImageNumber]];
    
    if(!thumbnailImage) {
        return [UIImage imageNamed:@"image-missing"];
    }
    
    return thumbnailImage;
}

- (UIImage*)getLevelImage {
    
    NSString * difficultyString = kExerciseLevelLabels[[self level]];
    NSString * imageFilename = [NSString stringWithFormat:@"exercise-difficulty-%@-icon", [difficultyString lowercaseString]];
    
    return [UIImage imageNamed:imageFilename];
}

- (NSString*)getLevelString {
    return [NSString stringWithFormat:@"%@ Difficulty", kExerciseLevelLabels[[self level]]];
}

- (NSString*)getLevelExplanationString {
    
    NSString * explanationString = nil;
    if([[self level] integerValue] == ExerciseLevelBasic) {
        explanationString = kBasicExplanationString;
        
    } else if([[self level] integerValue] == ExerciseLevelIntermediate) {
        explanationString = kIntermediateExplanationString;
        
    } else if([[self level] integerValue] == ExerciseLevelAdvanced) {
        explanationString = kAdvancedExplanationString;
    }
    
    return explanationString;
}

- (NSString*)getVideoFilePath {
    
    NSString * numberString = [[NSString stringWithFormat:@"%@", [self image]] uppercaseString];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:numberString ofType:@"m4v"];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:filePath]) {
//        NSLog(@"File does not exist in file system");
        return nil;
    }
    
    return filePath;
}

+ (Exercise*)exerciseWithIdentifier:(NSNumber*)identifier {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    
    NSError * error = nil;
    NSArray * results = nil;
    
    if(!(results = [[[self class] context] executeFetchRequest:fetchRequest error:&error])) {
        return nil;
    } else {
        return [results firstObject];
    }
}

// Takes a raw set of exercises retrieved from the database, including unpopulated overlap exercises
// and retrieves canonical exercises corresponding to overlap exercises. Then populates each overlap
// exercise with corresponding canonical exercise
+ (NSArray*)updateOverlappedWithExerciseInExerciseArray:(NSArray*)exerciseArray {
    
    // Retrieve all canonical numbers of overlapping exercises, so that they
    // can be retrieved all in one overly-large fetch request
    NSMutableArray * numbersToRetrieve = [[NSMutableArray alloc] init];
    
    for(Exercise * exercise in exerciseArray) {
        if(![exercise isCanonical]) {
            [numbersToRetrieve addObject:exercise.number];
        }
    }
    
    NSMutableArray * predicates = [[NSMutableArray alloc] init];
    
    // Create predicate to find canonical version of overlapping exercise
    for(NSNumber * number in numbersToRetrieve) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"number == %@ && nameTechnical.length > 0 && nameBasic.length > 0", number]];
    }
    
    NSPredicate * identifierCompoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
    NSFetchRequest * numbersFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    numbersFetchRequest.predicate = identifierCompoundPredicate;
    numbersFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    
    NSError * error = nil;
    NSArray * results = [[self class].context executeFetchRequest:numbersFetchRequest error:&error];
    
    // Match canonical to overlap
    BOOL allOverlappingExercisesMatchedWithCanonicalExercise = YES;
    
    for(Exercise * overlapExercise in exerciseArray) {
        
        // Exercise is canonical, no adjustment needs to be made
        if([overlapExercise isCanonical]) {
            continue;
        }
        
        for(Exercise * canonicalExercise in results) {
            if([canonicalExercise.number isEqual:overlapExercise.number]) {
                overlapExercise.canonicalExercise = canonicalExercise;
                break;
            }
        }
        
        if(!overlapExercise.canonicalExercise) {
            allOverlappingExercisesMatchedWithCanonicalExercise = NO;
        }
    }
    
    NSSortDescriptor *levelSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"level" ascending:YES];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"canonicalNameTechnical" ascending:YES];
    
    NSArray * sortedArray = [exerciseArray sortedArrayUsingDescriptors:@[ levelSortDescriptor, sortDescriptor ]];
    
    return sortedArray;
}

+ (NSDictionary*)categorizeExercisesByDifficulty:(NSArray*)rawExercises {
    
    NSMutableDictionary * exercisesMutable = [[NSMutableDictionary alloc] init];
    for(Exercise * exercise in rawExercises) {
        
        NSString * levelString = [exercise getLevelString];
        if(![[exercisesMutable allKeys] containsObject:levelString]) {
            exercisesMutable[levelString] = [[NSMutableArray alloc] init];
        }
        NSMutableArray * exercisesArrayForDifficulty = exercisesMutable[levelString];
        [exercisesArrayForDifficulty addObject:exercise];
        exercisesMutable[levelString] = exercisesArrayForDifficulty;
    }
    
    // Sort
    for(NSString * key in [exercisesMutable allKeys]) {
        NSMutableArray * exercisesWithDifficulty = exercisesMutable[key];
        [exercisesWithDifficulty sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((Exercise*)obj1).canonicalNameBasic compare:((Exercise*)obj2).canonicalNameBasic];
        }];
    }
    
    return exercisesMutable;
}

+ (NSArray*)generateDifficultiesForCategorizedExercises:(NSDictionary*)exercises {
    
    NSMutableArray * difficultiesMutable = [[NSMutableArray alloc] init];
    for(NSString * difficultyLabel in [kExerciseLevelLabels allValues]) {
        NSString * formattedDifficultyLabel = [NSString stringWithFormat:@"%@ Difficulty", difficultyLabel];
        
        if([[exercises allKeys] containsObject:formattedDifficultyLabel]) {
            [difficultiesMutable addObject:formattedDifficultyLabel];
        }
    }
    
    return difficultiesMutable;
}

#pragma mark - Property Override Methods

// Exercise is canonical if it includes both nameTechnical and nameBasic (among many other fields)
// Exercises that are overlap exercises only include number and type, the bare minimum for them to be identifiable
- (BOOL)isCanonical {
    return !((!self.nameBasic || [self.nameBasic length] == 0) && (!self.nameTechnical || [self.nameTechnical length] == 0));
}

- (NSString*)canonicalNameTechnical {
    if([self isCanonical]) {
        return self.nameTechnical;
    } else {
        return self.canonicalExercise.nameTechnical;
    }
}

- (NSString*)canonicalNameBasic {
    if([self isCanonical]) {
        return self.nameBasic;
    } else {
        return self.canonicalExercise.nameBasic;
    }
}

- (NSString*)canonicalNumber {
    if([self isCanonical]) {
        return self.number;
    } else {
        return self.canonicalExercise.number;
    }
}

- (NSString*)durationString {
    
    if([self.seconds integerValue] > 59) {
        
        float minutes = (((float)[self.seconds integerValue]) / 60.0f);
        
        NSString * minutesString = nil;
        if(((int)minutes) > 1 || minutes == 0) {
            minutesString = @"minutes";
        } else {
            minutesString = @"minute";
        }
        return [NSString stringWithFormat:@"%d %@", ((int)minutes), minutesString];
        
    } else {
        // No item is 1 second long, so no pluralization required
        return [NSString stringWithFormat:@"%d seconds", [self.seconds integerValue]];
    }
}

- (NSArray*)relatedExercises {
    
    if(_relatedExercises) {
        return _relatedExercises;
    }
    
    _relatedExercises = [self.related allObjects];
    if([_relatedExercises count] > 3) {
        _relatedExercises = [_relatedExercises subarrayWithRange:NSMakeRange(0, 3)];
    }
    
    return _relatedExercises;
}

@end
