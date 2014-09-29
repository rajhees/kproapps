//
//  ExerciseBlueButton.m
//  StretchMate
//
//  Created by James Eunson on 9/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseBlueButton.h"

#define kImageLookup @{ @(ExerciseBlueButtonTypeInfo): @"exercise-now-completing-info-icon", @(ExerciseBlueButtonTypeVideo): @"exercise-now-completing-video-icon", @(ExerciseBlueButtonTypeZoom): @"exercise-now-completing-zoom-icon" }

#define kHighlightedCellGradient @[ (id)[RGBCOLOR(5, 140, 245) CGColor], (id)[RGBCOLOR(1, 93, 230) CGColor] ]

@interface ExerciseBlueButton()
- (void)didTapButtonDown:(id)sender;
- (void)didTapButtonUp:(id)sender;
@end

@implementation ExerciseBlueButton

- (id)initWithFrame:(CGRect)frame type:(ExerciseBlueButtonType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.type = type;
        
        UIImageView * buttonBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"exercise-blue-button-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 7, 8, 7)]];
        buttonBackgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:buttonBackgroundView];
        
        CAGradientLayer * itemHighlightLayer = [CAGradientLayer layer];
        [itemHighlightLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 3)];
        itemHighlightLayer.actions = @{@"opacity": [NSNull null]};
        itemHighlightLayer.colors = kHighlightedCellGradient;
        itemHighlightLayer.cornerRadius = 8.0f;
        
        self.itemHighlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 3)];
        [_itemHighlightView.layer insertSublayer:itemHighlightLayer atIndex:0];
        _itemHighlightView.alpha = 0.0f;
        [self addSubview:self.itemHighlightView];
        
        NSString * imageFilename = kImageLookup[@(self.type)];
        UIImageView * infoButtonIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFilename]];
        infoButtonIconView.frame = CGRectMake(frame.size.width / 2 - infoButtonIconView.frame.size.width / 2, frame.size.height / 2 - infoButtonIconView.frame.size.height / 2, infoButtonIconView.frame.size.width, infoButtonIconView.frame.size.height);
        [self addSubview:infoButtonIconView];
        
        [self addTarget:self action:@selector(didTapButtonDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTapButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)didTapButtonDown:(id)sender {
    self.itemHighlightView.alpha = 1.0f;
}

- (void)didTapButtonUp:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.itemHighlightView.alpha = 0.0f;
    }];
}

@end
