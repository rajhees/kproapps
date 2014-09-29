//
//  ExerciseCell.h
//  StretchMate
//
//  Created by James Eunson on 28/11/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseStarView.h"

@interface ExerciseCell : UITableViewCell

@property (nonatomic, strong) ExerciseStarView * starView;
@property (nonatomic, strong) id selectedExercise;

@end
