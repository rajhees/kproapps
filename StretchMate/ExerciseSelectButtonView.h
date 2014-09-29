//
//  ExerciseMediaSelectButton.h
//  StretchMate
//
//  Created by James Eunson on 24/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ExerciseMediaButtonTypeImages,
    ExerciseMediaButtonTypeVideo,
    ExerciseMediaButtonTypeCustom
} ExerciseMediaButtonType;

@interface ExerciseSelectButtonView : UIView

@property (nonatomic, assign) ExerciseMediaButtonType type;
@property (nonatomic, strong) UIImageView * iconView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, assign, getter = isSelected) BOOL selected;

- (id)initWithFrame:(CGRect)frame andType:(ExerciseMediaButtonType)type andInitiallySelected:(BOOL)initiallySelected;

@end
