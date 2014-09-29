//
//  PractitionerExercise.m
//  Exersite
//
//  Created by James Eunson on 20/08/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PractitionerExercise.h"
#import "Exercise.h"

@implementation PractitionerExercise

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    self = [super initWithDictionary:dictionary error:error];
    if(self) {
        self.completed = NO;
    }
    return self;
}

- (NSString*)typesString {
    
    if(self.types) {
        return [self.types componentsJoinedByString:@", "];
    } else {
        return @"General Exercise";
    }
}

- (NSString*)getLevelString {
    
    if([[kExerciseLevelLabels allKeys] containsObject:self.level]) {
        return kExerciseLevelLabels[self.level];
    }
    return nil;
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

- (UIImage*)getLevelImage {
    
    NSString * imageFilename = [NSString stringWithFormat:@"exercise-difficulty-%@-icon", [[self getLevelString] lowercaseString]];
    return [UIImage imageNamed:imageFilename];
}

@end
