//
//  ExerciseMediaSelectorView.h
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseSelectButtonView.h"

@protocol ExerciseSelectionChangeDelegate;
@interface ExerciseSelectorView : UIView

@property (nonatomic, strong) UIImageView * selectedBackgroundView;
@property (nonatomic, assign) __unsafe_unretained id<ExerciseSelectionChangeDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedButton;
@property (nonatomic, assign, getter = isVideoEnabled) BOOL videoEnabled;

- (id)initWithFrame:(CGRect)frame options:(NSDictionary*)options;

@end

@protocol ExerciseSelectionChangeDelegate <NSObject>
- (void)exerciseSelectorView:(ExerciseSelectorView*)view didChangeSelection:(NSNumber*)selectionIndex;
@end
