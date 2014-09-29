//
//  ExerciseExporter.h
//  Exersite
//
//  Created by James Eunson on 3/07/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>

// Takes a pre-existing database of exercises and exports into a clean format for importing into the web apps
// Exported files will be ExersiteExercises.csv, ExerciseTypes.csv, ExerciseExercisesTypes.csv
// Contents respectively are exercises, types and exercise-type many-to-many relationships
@interface ExerciseExporter : NSObject

- (void)startExportWithCompletion:(void (^)(BOOL success))completionHandler;

@end
