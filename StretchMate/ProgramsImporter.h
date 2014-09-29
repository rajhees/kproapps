//
//  ProgramsImporter.h
//  StretchMate
//
//  Created by James Eunson on 12/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSV.h"

typedef void (^ProgramsImporterCompletionHandler)(BOOL success);

@interface ProgramsImporter : NSObject<CHCSVParserDelegate>

- (void)startImportWithCompletion:(void (^)(BOOL success))completionHandler;

@property (nonatomic, strong) NSMutableArray * allPrograms;
@property (nonatomic, copy) ProgramsImporterCompletionHandler completionHandler;

@end
