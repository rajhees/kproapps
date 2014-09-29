//
//  ProgramsImporter.m
//  StretchMate
//
//  Created by James Eunson on 12/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramsImporter.h"
#import "Program.h"
#import "AppDelegate.h"
#import "Exercise.h"

#define kProgramsSourceFile @"Programs.csv"

@interface ProgramsImporter()

@property (nonatomic, strong) NSManagedObjectContext * context;

@property (nonatomic, strong) NSMutableArray * currentFields;
@property (nonatomic, assign) NSInteger currentLineNumber;
@property (nonatomic, assign) NSInteger currentFieldIndex;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) Program * currentProgram;

@property (nonatomic, assign) BOOL currentLineShouldBeDiscarded;

@end

@implementation ProgramsImporter

- (void)startImportWithCompletion:(void (^)(BOOL))completionHandler {
    
    self.completionHandler = completionHandler;
    
    self.currentIndex = 1;
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.context = [delegate managedObjectContext];
    
    // Import programs
    NSArray * filenameComponents = [kProgramsSourceFile componentsSeparatedByString:@"."];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:filenameComponents[0] ofType:filenameComponents[1]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"File does not exist in file system");
        return;
    }
    
    NSError * error = nil;
    CHCSVParser * programsParser = [[CHCSVParser alloc] initWithContentsOfCSVFile:filePath encoding:NSASCIIStringEncoding error:&error];
    programsParser.parserDelegate = self;
    [programsParser parse];
}

- (void) parser:(CHCSVParser *)parser didStartDocument:(NSString *)csvFile {
//    NSLog(@"ProgramsImporter: didStartDocument");
    
    self.allPrograms = [[NSMutableArray alloc] init];
    self.currentFields = [[NSMutableArray alloc] init];
}

- (void) parser:(CHCSVParser *)parser didStartLine:(NSUInteger)lineNumber {
//    NSLog(@"ProgramsImporter: didStartLine");
    
    self.currentLineNumber = lineNumber;
    self.currentLineShouldBeDiscarded = NO;
    self.currentFieldIndex = 0;
    
    if(lineNumber != 1) {
        self.currentProgram = (Program*)[NSEntityDescription insertNewObjectForEntityForName:@"Program" inManagedObjectContext:self.context];
        self.currentProgram.identifier = @(self.currentIndex);
    }
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
//    NSLog(@"ProgramsImporter: didEndLine");

    // First line should never be saved, as it is fields listing
    if(lineNumber == 1) return;
    
    if(self.currentLineShouldBeDiscarded && self.currentProgram) {
        [self.context deleteObject: self.currentProgram];
    } else {
        self.currentIndex++;
    }
    
    NSError * error = nil;
    if(![self.context save:&error]) {
        NSLog(@"Error saving exercise");
    }
    
    [self.allPrograms addObject:self.currentProgram];
    
}

- (void) parser:(CHCSVParser *)parser didReadField:(NSString *)field {
//    NSLog(@"ProgramsImporter: didReadField: %@", field);
    
    if(self.currentLineNumber == 1) {
        [self.currentFields addObject:field];
        
    } else {
        
        NSString * fieldName = [self.currentFields[self.currentFieldIndex] lowercaseString];
//        NSLog(@"ProgramsImporter: didReadField (%@): %@", fieldName, field);
        
        if([fieldName isEqualToString:[@"Program" lowercaseString]]
           || [fieldName isEqualToString:[@"Exercises" lowercaseString]]) {
            
            if([field length] == 0 || !field) {
                self.currentLineShouldBeDiscarded = YES;
            }
        }
        
        if([fieldName isEqualToString:[@"Program" lowercaseString]]) {
            self.currentProgram.title = field;
            
        } else if([fieldName isEqualToString:[@"Exercises" lowercaseString]]) {
            
            NSArray * exerciseCodes = [field componentsSeparatedByString:@","];
            for(__strong NSString * exerciseCode in exerciseCodes) {

                exerciseCode = [exerciseCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSError * error = nil;                
                NSFetchRequest * exerciseRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
                [exerciseRequest setPredicate:[NSPredicate predicateWithFormat:@"number == %@ && nameTechnical.length > 0 && nameBasic.length > 0", exerciseCode]];
                NSArray * results = [self.context executeFetchRequest:exerciseRequest error:&error];
                
                if(error != nil || results == nil || [results count] == 0 || [results count] > 1) { // Any deviance from expected result
                    NSLog(@"problem with exercise %d", [exerciseCode intValue]);
                    for(Exercise * resultExercise in results) {
                        NSLog(@"exercise: %@ %@", resultExercise.nameTechnical, resultExercise.number);
                    }
                    continue;
                }
                
                Exercise * retrievedExercise = [results firstObject];
                if(retrievedExercise) {
                    [self.currentProgram addExercisesObject:retrievedExercise];
                } else {
                    NSLog(@"problem");
                }
                
//                NSLog(@"Successfully Retrieved Exercise %@", exerciseCode);                
            }
            
        } else if([fieldName isEqualToString:[@"Description" lowercaseString]]) {
            self.currentProgram.programDescription = field;
        }
    }
    
    self.currentFieldIndex++;    
}

- (void) parser:(CHCSVParser *)parser didEndDocument:(NSString *)csvFile {
//    NSLog(@"ProgramsImporter: didEndDocument");
    self.completionHandler(YES);
}

- (void) parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
//    NSLog(@"ProgramsImporter: didFailWithError");
}

@end