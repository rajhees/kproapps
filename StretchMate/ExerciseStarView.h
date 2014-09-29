//
//  ExerciseStarView.h
//  StretchMate
//
//  Created by James Eunson on 29/11/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kStarViewWidth 18.0f

typedef enum {
    StarViewSizeSmall,
    StarViewSizeLarge
} StarViewSize;

typedef enum {
    StarBackgroundColorOrange,
    StarBackgroundColorBlue,
    StarBackgroundColorDarkBlue,
} StarBackgroundColor;

@interface ExerciseStarView : UIView

- (id)initWithFrame:(CGRect)frame size:(StarViewSize)size color:(StarBackgroundColor)color;

@property (nonatomic, strong) UILabel * starLabel;
@property (nonatomic, strong) UIView * starBackgroundView;
@property (nonatomic, assign) StarViewSize size;
@property (nonatomic, assign) StarBackgroundColor starBackgroundColor;

@end
