//
//  ExerciseNowCompletingPageButton.m
//  StretchMate
//
//  Created by James Eunson on 12/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingPageButton.h"

#define kImageLookup @{ @(PageButtonDirectionPrevious): @"exercise-now-completing-page-number-previous", @(PageButtonDirectionNext): @"exercise-now-completing-page-number-next" }

#define kHighlightedCellGradient @[ (id)[RGBCOLOR(5, 140, 245) CGColor], (id)[RGBCOLOR(1, 93, 230) CGColor] ]

@interface ExerciseNowCompletingPageButton()
- (void)didTapButtonDown:(id)sender;
- (void)didTapButtonUp:(id)sender;
@end

@implementation ExerciseNowCompletingPageButton

- (id)initWithFrame:(CGRect)frame direction:(PageButtonDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.direction = direction;
        
        CAGradientLayer * itemHighlightLayer = [CAGradientLayer layer];
        [itemHighlightLayer setFrame:CGRectMake(0, 0, frame.size.width - 6, frame.size.height - 12)];
        itemHighlightLayer.actions = @{@"opacity": [NSNull null]};
        itemHighlightLayer.colors = kHighlightedCellGradient;
        itemHighlightLayer.cornerRadius = 8.0f;
        
        self.highlightView = [[UIView alloc] initWithFrame:CGRectMake(3, 6, frame.size.width - 6, frame.size.height - 12)];
        [_highlightView.layer insertSublayer:itemHighlightLayer atIndex:0];
        _highlightView.alpha = 0.0f;
        [self addSubview:self.highlightView];
        
        NSString * imageFilename = kImageLookup[@(direction)];
        
        UIImageView * buttonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFilename]];
        CGRect buttonFrame = CGRectZero;
        if(direction == PageButtonDirectionPrevious) {
            buttonFrame = CGRectMake(6, 9, buttonImageView.frame.size.width, buttonImageView.frame.size.height);
        } else {
            buttonFrame = CGRectMake(frame.size.width - buttonImageView.frame.size.width - 8, 9, buttonImageView.frame.size.width, buttonImageView.frame.size.height);
        }
        buttonImageView.frame = buttonFrame;
        buttonImageView.alpha = 0.25f;
        
        [self addSubview:buttonImageView];
        
        CGRect directionFrame = CGRectZero;
        if(direction == PageButtonDirectionPrevious) {
            directionFrame = CGRectMake((6 + buttonImageView.frame.size.width + 7), 0, frame.size.width - (6 + buttonImageView.frame.size.width + 7), 38);
        } else {
            directionFrame = CGRectMake(6, 0, frame.size.width - (6 + buttonImageView.frame.size.width + 7), 38);
        }
        
        self.directionLabel = [[UILabel alloc] initWithFrame:directionFrame];
        
        _directionLabel.backgroundColor = [UIColor clearColor];
        _directionLabel.textColor = RGBCOLOR(115, 116, 123);
        _directionLabel.numberOfLines = 1;
        _directionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _directionLabel.text = @"Name of exercise is long and should be truncated";
        _directionLabel.font = [UIFont systemFontOfSize:11.0f];
        
        [self addSubview:self.directionLabel];
        
        [self addTarget:self action:@selector(didTapButtonDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTapButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)didTapButtonDown:(id)sender {
    self.highlightView.alpha = 1.0f;
}

- (void)didTapButtonUp:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.highlightView.alpha = 0.0f;
    }];
}

@end
