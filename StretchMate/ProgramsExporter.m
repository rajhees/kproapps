//
//  ProgramsExporter.m
//  Exersite
//
//  Created by James Eunson on 3/07/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramsExporter.h"
#import "Program.h"
#import "Exercise.h"
#import "AppDelegate.h"

#define kExercisesCSVFilename @"ExersitePrograms.csv"

@interface ProgramsExporter ()

@property (nonatomic, strong) NSManagedObjectContext * context;

@end

@implementation ProgramsExporter

- (void)startExportWithCompletion:(void (^)(BOOL success))completionHandler {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.context = [delegate managedObjectContext];
    
    NSFetchRequest * allProgramsFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Program"];
    NSMutableString * programsCSVString = [[NSMutableString alloc] init];
    
    NSError * error = nil;
    NSArray * results = [self.context executeFetchRequest:allProgramsFetchRequest error:&error];
    
    NSString * fields = @"id,title,exercises\n";
    [programsCSVString appendString:fields];
    
    NSInteger i = 1;
    for(Program * program in results) {
        
        NSMutableArray * exerciseIdentifiers = [@[] mutableCopy];
        NSArray * exercises = [program.exercises allObjects];
        
        for(Exercise * exercise in exercises) {
            [exerciseIdentifiers addObject:exercise.identifier];
        }
        
        NSString * concatExerciseIdentifiersString = [exerciseIdentifiers componentsJoinedByString:@","];
        NSString * formattedStringForLine = [NSString stringWithFormat:@"%d,\"%@\",\"%@\"\n", i, program.title, concatExerciseIdentifiersString];
        [programsCSVString appendString:formattedStringForLine];
        
        i++;
    }
    
    NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * programsCSVURL = [applicationDocumentsDirectory URLByAppendingPathComponent:kExercisesCSVFilename];
    
    [programsCSVString writeToFile:[programsCSVURL path] atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end

