//
//  ImportExercises.m
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseImporter.h"
#import "AppDelegate.h"
#import "NSArray+FirstObject.h"
#import "RegexKitLite/RegexKitLite.h"

#define kExerciseSourceFiles @[@"Ankle and Foot.csv", @"Core Pilates.csv", @"Elbow and Wrist.csv", @"Hip.csv", @"Knee.csv", @"Lumbar.csv", @"Neck.csv", @"Jaw.csv", @"Shoulder.csv", @"Thoracic.csv"]

#define kExerciseFilenameMapping @{ \
    @"Ankle and Foot.csv": @"Ankle & Foot", \
    @"Core Pilates.csv": @"Core & Pilates", \
    @"Elbow and Wrist.csv": @"Elbow & Wrist", \
    @"Hip.csv": @"Hip", \
    @"Knee.csv": @"Knee", \
    @"Lumbar.csv": @"Lower Back (Lumbar)", \
    @"Neck.csv": @"Neck (Cervical)", \
    @"Jaw.csv": @"Jaw (TMJ)", \
    @"Shoulder.csv": @"Shoulder", \
    @"Thoracic.csv": @"Upper Back (Thoracic)" \
}

@interface ExerciseImporter()

@property (nonatomic, strong) NSManagedObjectContext * context;

@property (nonatomic, strong) Exercise * currentExercise;
@property (nonatomic, strong) NSMutableArray * currentSheetExercises;
@property (nonatomic, strong) NSString * currentSheetName;

@property (nonatomic, strong) NSMutableDictionary * relatedExercises; // Held until the end, cannot do until all exercises are in

@property (nonatomic, strong) NSMutableArray * currentSheetFields;
@property (nonatomic, assign) NSInteger currentSheetLineNumber;
@property (nonatomic, assign) NSInteger currentFieldIndex;
@property (nonatomic, assign) NSInteger currentExerciseIndex;
@property (nonatomic, assign) BOOL currentLineShouldBeDiscarded;

@property (nonatomic, assign, getter = isInOverlappingSection) BOOL inOverlappingSection;

- (void)_updateExercisesWithCustomImageMappings;
- (void)_addRelatedExercisesToExercises;

@end

@implementation ExerciseImporter

- (void)startImportWithCompletion:(void (^)(BOOL success))completionHandler {
    
    self.completionHandler = completionHandler;
    
    self.allExercises = [[NSMutableDictionary alloc] init];
    self.relatedExercises = [[NSMutableDictionary alloc] init];
    
    self.currentExerciseIndex = 1;
    self.inOverlappingSection = NO;
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.context = [delegate managedObjectContext];
    
    // Import exercises, from each source file. Source files are organised based on location in the body
    for(NSString * filename in kExerciseSourceFiles) {
        
        NSArray * filenameComponents = [filename componentsSeparatedByString:@"."];
        NSString * filePath = [[NSBundle mainBundle] pathForResource:filenameComponents[0] ofType:filenameComponents[1]];
//        NSLog(@"filePath: %@", filePath);
        
        NSFileManager * fm = [NSFileManager defaultManager];
        
        if(![fm fileExistsAtPath:filePath]) {
//            NSLog(@"File does not exist in file system");
            return;
        }
        
        NSError * error = nil;
        CHCSVParser * parser = [[CHCSVParser alloc] initWithContentsOfCSVFile:filePath encoding:NSMacOSRomanStringEncoding error:&error];
        parser.parserDelegate = self;
        [parser parse];
    }
}

- (void) parser:(CHCSVParser *)parser didStartDocument:(NSString *)csvFile {
//    NSLog(@"ExerciseImporter: didStartDocument");
    
    self.currentSheetExercises = [[NSMutableArray alloc] init];
    self.currentSheetFields = [[NSMutableArray alloc] init];
    self.currentSheetName = csvFile;
    self.inOverlappingSection = NO;
}

- (void) parser:(CHCSVParser *)parser didStartLine:(NSUInteger)lineNumber {
//    NSLog(@"ExerciseImporter: didStartLine");
    
    self.currentSheetLineNumber = lineNumber;
    self.currentLineShouldBeDiscarded = NO;
    self.currentFieldIndex = 0;
    
    if(lineNumber != 1) {
        self.currentExercise = (Exercise*)[NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:self.context];
        self.currentExercise.identifier = @(self.currentExerciseIndex);
    }
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
//    NSLog(@"ExerciseImporter: didEndLine");
    
    // First line should never be saved, as it is fields listing
    if(lineNumber == 1) return;
    
    if(self.currentLineShouldBeDiscarded && self.currentExercise) {
        [self.context deleteObject: self.currentExercise];
    } else {
        self.currentExerciseIndex++;
    }
    
    NSError * error = nil;
    if(![self.context save:&error]) {
//        NSLog(@"Error saving exercise");
    }
    
    [self.currentSheetExercises addObject:self.currentExercise];
}

- (void) parser:(CHCSVParser *)parser didReadField:(NSString *)field {
    
    if(self.currentSheetLineNumber == 1) {
        [self.currentSheetFields addObject:field];
        
    } else {
        
        if([[field lowercaseString] isEqualToString:@"overlapping exercises"]) {
            
//            NSLog(@"Overlapping Exercises encountered");
            
            self.inOverlappingSection = YES;
            self.currentLineShouldBeDiscarded = YES;
            self.currentFieldIndex++;
            return;
        }
        
        NSString * fieldName = [self.currentSheetFields[self.currentFieldIndex] lowercaseString];
//        NSLog(@"ExerciseImporter: didReadField (%@): %@", fieldName, field);
        
        // Check for associated non-nil values for all mandatory fields
        // Absence of one is cause for disqualification, and will present as an NSLog message indicating malformed exercise
        if([fieldName isEqualToString:[@"Number" lowercaseString]] // Equipment removed from here, because it can be null
           || [fieldName isEqualToString:[@"Exercise Name Technical" lowercaseString]]                      
           || [fieldName isEqualToString:[@"Exercise Name Translated" lowercaseString]]           
           || [fieldName isEqualToString:[@"Type of Exercise" lowercaseString]]
           || [fieldName isEqualToString:[@"Description" lowercaseString]]
           || [fieldName isEqualToString:[@"Level" lowercaseString]]
           || [fieldName isEqualToString:[@"Stopwatch" lowercaseString]]
           || [fieldName isEqualToString:[@"Purpose" lowercaseString]]) {
            
            // Strict validation should only occur when in a normal section, incomplete entries
            // in an overlapping section are fine and occur frequently without actually being an error
            if(([field length] == 0 || !field) && !self.isInOverlappingSection) {
//                NSLog(@"Discarding %@, line: %d, because %@ value %@ is empty or non-existent", self.currentSheetName, self.currentSheetLineNumber, fieldName, field);
                self.currentLineShouldBeDiscarded = YES;
            }
        }
        
        // When in an overlapping section, only the number and type should be recorded
        if(self.isInOverlappingSection && ![fieldName isEqualToString:[@"Number" lowercaseString]] && ![fieldName isEqualToString:[@"Type of Exercise" lowercaseString]]) {
//            NSLog(@"unnecessary field for overlapping: %@", fieldName);
            return;
        }
        
        if([fieldName isEqualToString:[@"Number" lowercaseString]]) {
            
            if([field intValue] == 0 && !self.currentLineShouldBeDiscarded) {
//                NSLog(@"problem");
            }
            
            NSString * cleanedNumberString = [[field componentsSeparatedByCharactersInSet:
                                    [[NSCharacterSet alphanumericCharacterSet] invertedSet]]
                                   componentsJoinedByString:@""];
            
            self.currentExercise.number = cleanedNumberString;
            self.currentExercise.image = cleanedNumberString;
            
        } else if([fieldName isEqualToString:[@"Exercise Name Technical" lowercaseString]]) {
            self.currentExercise.nameTechnical = field;
        
        } else if([fieldName isEqualToString:[@"Exercise Name Translated" lowercaseString]]) {
            self.currentExercise.nameBasic = field;

        } else if([fieldName isEqualToString:[@"Type of Exercise" lowercaseString]]) {
            
            // Type is a combination type and should be split according to delimiting character
            NSMutableArray * subtypes = [[NSMutableArray alloc] init];
            if([field rangeOfString:@"/"].location != NSNotFound) {
                
                NSArray * subtypeComponents = [field componentsSeparatedByString:@"/"];
                for(__strong NSString * subtype in subtypeComponents) {
                    subtype = [[subtype stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] capitalizedString];
                    [subtypes addObject:subtype];
                }
                
            } else {
                [subtypes addObject:[field capitalizedString]];
            }
            
            for(__strong NSString * subtype in subtypes) {
                
                if([subtype length] == 0 || !subtype) continue;
                
                NSError * error = nil;
                ExerciseType * type = [ExerciseType getExerciseTypeByName:subtype];
                
                if(type) {
                    [self.currentExercise addTypesObject:type];
                    
                } else {
                    ExerciseType * newType = (ExerciseType*)[NSEntityDescription insertNewObjectForEntityForName:@"ExerciseType" inManagedObjectContext:self.context];
                    newType.name = subtype;
                    [self.context save:&error];
                    
                    [self.currentExercise addTypesObject:newType];
                }
            }
            
        } else if([fieldName isEqualToString:[@"Description" lowercaseString]]) {      
            
            // Clean leading and trailing newlines and whitespace, so a string without internal
            // newlines is not misinterpreted as having internal newlines
            NSString * cleanedField = [field stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            // Data includes no new line characters to delineate steps in instructions, have to resort to scanning
//            NSLog(@"problem");
            
            NSMutableArray * mutableInstructions = [[NSMutableArray alloc] init];
            NSArray * components = [cleanedField componentsSeparatedByRegex:@"[0-9]+\\)"]; // Manually extracted components using regex
            
            int i = 1;
            for(__strong NSString * component in components) {
                
                component = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if([component length] == 0 || !component) continue;
                
                NSString * numberedInstruction = [NSString stringWithFormat:@"%d) %@", i, component];
                [mutableInstructions addObject:numberedInstruction];
                i++;
            }
            
            self.currentExercise.instructions = [NSArray arrayWithArray:mutableInstructions];
            
        } else if([fieldName isEqualToString:[@"Level" lowercaseString]]) {
            
            int exerciseLevelInt = -1, i = 0;

            if([field length] != 0) {
                for(NSString * levelLabel in [kExerciseLevelLabels allValues]) {
                    if([[[levelLabel substringToIndex:1] lowercaseString] isEqualToString:[[field lowercaseString] substringToIndex:1]]) {
                        exerciseLevelInt = i;
                        break;
                    }
                    i++;
                }
            }
            
            if(exerciseLevelInt == -1 && !self.currentLineShouldBeDiscarded) { // Only register a problem if current line should not be discarded
//                NSLog(@"problem");
            }
            
            self.currentExercise.level = @(exerciseLevelInt);
            
        } else if([fieldName isEqualToString:[@"Equipment" lowercaseString]]) { // @TODO: Expand into actual product recognition, associate with product in Shop to enable clickthrough
            
            if(![[field lowercaseString] isEqualToString:@"nil"]) {
                self.currentExercise.equipment = field;
            }
            
        } else if([fieldName isEqualToString:[@"Stopwatch" lowercaseString]]) {
            self.currentExercise.seconds = @([field intValue]);
            
        } else if([fieldName isEqualToString:[@"Purpose" lowercaseString]]) {
            self.currentExercise.purpose = field;
            
        } else if([fieldName isEqualToString:[@"Related" lowercaseString]]) {
            
            if([field length] != 0 && field != nil) {
                
                NSMutableArray * relatedExerciseIdentifiers = [@[] mutableCopy];
                NSArray * rawIdentifiers = [field componentsSeparatedByString:@","];
                for(NSString * rawIdentifier in rawIdentifiers) {
                    [relatedExerciseIdentifiers addObject:[rawIdentifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                }
                
                if([relatedExerciseIdentifiers count] > 0) {
                    if([self.currentExercise.number length] != 0) {
                        self.relatedExercises[self.currentExercise.number] = relatedExerciseIdentifiers;
                    }
                }
            }
            
        } else {
            if([fieldName length] != 0 && fieldName != nil) {
//                NSLog(@"Unrecognized field: %@", fieldName);         
            }
        }
    
        // Set exercise location based on sheet name
//        NSString * shortSheetName = [[[[self.currentSheetName componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject];
        NSString * shortSheetName = [[self.currentSheetName componentsSeparatedByString:@"/"] lastObject];        
        NSString * mappedLocationName = kExerciseFilenameMapping[shortSheetName];
        self.currentExercise.location = [Exercise getTypeForLocationString:mappedLocationName];
    }
    
    self.currentFieldIndex++;
}

- (void) parser:(CHCSVParser *)parser didEndDocument:(NSString *)csvFile {
//    NSLog(@"ExerciseImporter: didEndDocument");
    
    NSArray * filenameComponents = [csvFile componentsSeparatedByString:@"."];
    self.allExercises[filenameComponents[0]] = [[NSArray alloc] initWithArray:self.currentSheetExercises];
    _currentSheetExercises = nil;
    
    // Determine whether parsing is completely over
    if([[kExerciseSourceFiles lastObject] isEqualToString:[[csvFile componentsSeparatedByString:@"/"] lastObject]]) {
        
        [self _updateExercisesWithCustomImageMappings];
        [self _addRelatedExercisesToExercises];
        
        self.completionHandler(YES);
    }
}

- (void) parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
//    NSLog(@"ExerciseImporter: didFailWithError");
}

- (void)_updateExercisesWithCustomImageMappings {

    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"ExerciseImageCustomMappings" ofType:@"plist"];
    NSArray * mappingsArray = [NSArray arrayWithContentsOfFile:filePath];

    
    for(NSDictionary * mapping in mappingsArray) {
//        NSLog(@"mapping");
        
        NSFetchRequest * request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
        request.predicate = [NSPredicate predicateWithFormat:@"number == %@ && nameTechnical.length > 0 && nameBasic.length > 0", mapping[@"number"]];
        
        NSError * error = nil;
        NSArray * results = [self.context executeFetchRequest:request error:&error];
        
        if(!results || [results count] == 0 || error || [results count] != 1) {
//            NSLog(@"Error retrieving exercise for assigning image mapping");
        }
        
        Exercise * exercise = [results firstObject];
        exercise.image = mapping[@"image"];
        
        [self.context save:&error];
    }
}

- (void)_addRelatedExercisesToExercises {
    
    for(NSString * exerciseIdentifier in [self.relatedExercises allKeys]) {
        
        NSError * error = nil;        
        
        // Get exercise that should be related to other exercises
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"number == %@ && nameTechnical.length > 0 && nameBasic.length > 0", exerciseIdentifier];
        NSArray * resultsForExerciseFetchRequest = [self.context executeFetchRequest:fetchRequest error:&error];
        
        if(!resultsForExerciseFetchRequest || [resultsForExerciseFetchRequest count] == 0) {
            return;
        }
        
        Exercise * targetExercise = [resultsForExerciseFetchRequest firstObject];
        if([[targetExercise.nameBasic lowercaseString] rangeOfString:@"transverse"].location != NSNotFound || [[targetExercise.nameTechnical lowercaseString] rangeOfString:@"transverse"].location != NSNotFound) {
//            NSLog(@"bad related item found");
        }
        
        // Get related exericses
        NSArray * relatedExerciseIdentifiers = self.relatedExercises[exerciseIdentifier];
        NSMutableArray * predicates = [@[] mutableCopy];        
        
        // Get canonical exercise for identifier
        for(NSString * identifier in relatedExerciseIdentifiers) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"number == %@ && nameTechnical.length > 0 && nameBasic.length > 0", identifier]];
        }
        
        NSPredicate * identifierCompoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
        
        NSFetchRequest * numbersFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
        numbersFetchRequest.predicate = identifierCompoundPredicate;
        numbersFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
        
        NSArray * relatedExercises = [self.context executeFetchRequest:numbersFetchRequest error:&error];
        
        if(relatedExercises && [relatedExercises count] > 0) {
            for(Exercise * relatedExercise in relatedExercises) {
                [targetExercise addRelatedObject:relatedExercise];
            }
            
            NSError * error = nil;
            [self.context save:&error];
            
            if(error) {
//                NSLog(@"Error saving related");
            }
        } else {
//            NSLog(@"Related exercise retrieval failed: %@", relatedExerciseIdentifiers);
        }
    }
}

@end