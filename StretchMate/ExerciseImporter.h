//
//  ImportExercises.h
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Exercise.h"
#import "ExerciseType.h"
#import "CHCSV.h"

typedef void (^ExerciseImporterCompletionHandler)(BOOL success);

@interface ExerciseImporter : NSObject <CHCSVParserDelegate>

- (void)startImportWithCompletion:(void (^)(BOOL success))completionHandler;

@property (nonatomic, strong) NSMutableDictionary * allExercises;

// Debug only, full range of encountered exercise types
@property (nonatomic, strong) NSMutableArray * ignoredItems;
@property (nonatomic, copy) ExerciseImporterCompletionHandler completionHandler;

@end
