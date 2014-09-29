//
//  ExerciseBigButton.h
//  Exersite
//
//  Created by James Eunson on 26/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopBigButton.h"

typedef enum {
    ExerciseBigButtonTypeAddToMyExercises,
    ExerciseBigButtonTypeStartExercise,
    ExerciseBigButtonTypeImFinished,
    ExerciseBigButtonTypeOkGotIt
} ExerciseBigButtonType;

@interface ExerciseBigButton : ShopBigButton

@property (nonatomic, assign) ExerciseBigButtonType exerciseButtonType;

@end
