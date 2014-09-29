//
//  ExerciseMediaSelectButton.h
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseSelectButtonView.h"

@interface ExerciseMediaSelectButton : UIButton

@property (nonatomic, strong) ExerciseSelectButtonView * buttonView;
@property (nonatomic, assign) ExerciseMediaButtonType type;
@property (nonatomic, strong) UIView * shadeView;

- (id)initWithFrame:(CGRect)frame andType:(ExerciseMediaButtonType)type;

@end
