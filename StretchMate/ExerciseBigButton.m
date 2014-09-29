//
//  ExerciseBigButton.m
//  Exersite
//
//  Created by James Eunson on 26/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseBigButton.h"

@implementation ExerciseBigButton

#pragma mark - Property Override
- (void)setExerciseButtonType:(ExerciseBigButtonType)exerciseButtonType {
    _exerciseButtonType = exerciseButtonType;
    
    if(exerciseButtonType == ExerciseBigButtonTypeAddToMyExercises) {
        
        self.addToCartLabel.text = @"Add to My Exercises";
        self.addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(exerciseButtonType == ExerciseBigButtonTypeStartExercise) {

        self.addToCartLabel.text = @"Start Exercise";
        self.addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(exerciseButtonType == ExerciseBigButtonTypeImFinished) {
        
        self.addToCartLabel.text = @"I'm Finished";
        self.addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(exerciseButtonType == ExerciseBigButtonTypeOkGotIt) {
        
        self.addToCartLabel.text = @"Ok, got it";
        self.addToCartBackgroundView.backgroundColor = kTintColour;
    }
        
}

@end
