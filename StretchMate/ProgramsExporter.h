//
//  ProgramsExporter.h
//  Exersite
//
//  Created by James Eunson on 3/07/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgramsExporter : NSObject

- (void)startExportWithCompletion:(void (^)(BOOL success))completionHandler;

@end
