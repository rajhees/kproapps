//
//  ExerciseStarView.m
//  StretchMate
//
//  Created by James Eunson on 29/11/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseStarView.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define kStarString @"★"

#define kStarSmallFontSize 9.0f
#define kStarLargeFontSize 15.0f

#define kStarBackgroundColors @[ kTintColour, RGBCOLOR(227, 213, 191), RGBCOLOR(20, 27, 54) ]
#define kLargeStarBackgroundColors @[ kDarkTintColour, RGBCOLOR(227, 213, 191), RGBCOLOR(20, 27, 54) ]
#define kStarTextColors @[ RGBCOLOR(255, 255, 255), RGBCOLOR(255, 255, 255), RGBCOLOR(84, 96, 141) ]

@implementation ExerciseStarView

- (id)initWithFrame:(CGRect)frame size:(StarViewSize)size color:(StarBackgroundColor)color
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.size = size;
        
        CGFloat starFontSize = (size == StarViewSizeSmall ? kStarSmallFontSize : kStarLargeFontSize);
        
        if(size == StarViewSizeSmall) {
            self.starBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, -12.0f, 25.0f, 25.0f)];
        } else {
            self.starBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(12.0f, -24.0f, 50.0f, 50.0f)];
        }
        _starBackgroundView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45.0f));
        [self addSubview:self.starBackgroundView];
        
        CGSize starSize = [kStarString sizeWithFont:[UIFont systemFontOfSize:starFontSize]];
        
        if(size == StarViewSizeSmall) {
            self.starLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - starSize.width, -3.0f, frame.size.width, frame.size.height)];
        } else {
            self.starLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - starSize.width - 2.0f, -6.0f, frame.size.width, frame.size.height)];
        }
        _starLabel.backgroundColor = [UIColor clearColor];
        _starLabel.font = [UIFont systemFontOfSize:starFontSize];
        _starLabel.text = kStarString;
        
        self.starBackgroundColor = color;        
        self.userInteractionEnabled = NO;
        
        [self addSubview:self.starLabel];
        
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setStarBackgroundColor:(StarBackgroundColor)starBackgroundColor {
    _starBackgroundColor = starBackgroundColor;
    
    NSArray * starBackgroundColors = (self.size == StarViewSizeSmall ? kStarBackgroundColors : kLargeStarBackgroundColors);
    
    [UIView animateWithDuration:0.3f animations:^{
        _starBackgroundView.backgroundColor = starBackgroundColors[_starBackgroundColor];
        _starLabel.textColor = kStarTextColors[_starBackgroundColor];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
