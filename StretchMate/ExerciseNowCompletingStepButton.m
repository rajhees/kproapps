//
//  ExerciseNowCompletingStepButton.m
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingStepButton.h"

@interface ExerciseNowCompletingStepButton ()

@property (nonatomic, strong) UIView * highlightView;

@property (nonatomic, strong) CALayer * topBorder;
@property (nonatomic, strong) CALayer * leftBorder;

- (void)didTouchUpInside:(id)sender;
- (void)didTouchDown:(id)sender;

@end

@implementation ExerciseNowCompletingStepButton

- (id)initWithType:(ExerciseNowCompletingStepButtonType)type {
    self = [super init];
    if(self) {
        
        self.stepLabel = [[UILabel alloc] init];
        _stepLabel.backgroundColor = [UIColor clearColor];
        _stepLabel.textColor = kTintColour;
        _stepLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_stepLabel];
        
        self.stepImageView = [[UIImageView alloc] init];
        [self addSubview:_stepImageView];
        
        self.disabledStepImageView = [[UIImageView alloc] init];
        _disabledStepImageView.hidden = YES;
        [self addSubview:_disabledStepImageView];
        
        self.topBorder = [CALayer layer];
        _topBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_topBorder atIndex:100];
        
        self.leftBorder = [CALayer layer];
        _leftBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        _leftBorder.hidden = YES;
        [self.layer insertSublayer:_leftBorder atIndex:101];
        
        self.highlightView = [[UIView alloc] init];
        _highlightView.backgroundColor = RGBCOLOR(5, 140, 245);
        _highlightView.alpha = 0;
        [self addSubview:_highlightView];
        [self sendSubviewToBack:_highlightView];
        
        [self addTarget:self action:@selector(didTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpOutside];
        
        self.type = type;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForStepLabel = [_stepLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    self.stepLabel.frame = CGRectMake(8.0f, (self.frame.size.height / 2) - (sizeForStepLabel.height / 2), sizeForStepLabel.width, sizeForStepLabel.height);
    
    self.stepImageView.frame = CGRectMake(self.frame.size.width - 8.0f - _stepImageView.frame.size.width, (self.frame.size.height / 2) - (_stepImageView.frame.size.height / 2), _stepImageView.frame.size.width, _stepImageView.frame.size.height);
    
    self.disabledStepImageView.frame = CGRectMake(self.frame.size.width - 8.0f - _disabledStepImageView.frame.size.width, (self.frame.size.height / 2) - (_disabledStepImageView.frame.size.height / 2), _disabledStepImageView.frame.size.width, _disabledStepImageView.frame.size.height);
    
    self.highlightView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.topBorder.frame = CGRectMake(0, 0, self.frame.size.width, 1.0f);
    self.leftBorder.frame = CGRectMake(0, 0, 1.0f, self.frame.size.height);
}

#pragma mark - Property Override
- (void)setType:(ExerciseNowCompletingStepButtonType)type {
    _type = type;
    
    if(type == ExerciseNowCompletingStepButtonTypePrevious) {
        
        _stepLabel.text = @"Previous Step";
        _stepImageView.image = [UIImage imageNamed:@"exercise-now-completing-previous-step-icon-ios7"];
        _disabledStepImageView.image = [UIImage imageNamed:@"exercise-now-completing-previous-step-icon-disabled-ios7"];
        
    } else if(type == ExerciseNowCompletingStepButtonTypeNext) {
        
        _stepLabel.text = @"Next Step";
        _stepImageView.image = [UIImage imageNamed:@"exercise-now-completing-next-step-icon-ios7"];
        _disabledStepImageView.image = [UIImage imageNamed:@"exercise-now-completing-next-step-icon-disabled-ios7"];
        
        _leftBorder.hidden = NO;
    }
    
    [_stepImageView sizeToFit];
    [_disabledStepImageView sizeToFit];
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (void)didTouchDown:(id)sender {
//    NSLog(@"didTouchDown:");
    
    _highlightView.alpha = 1.0f;
    
    self.stepLabel.textColor = [UIColor whiteColor];
}

- (void)didTouchUpInside:(id)sender {
//    NSLog(@"didTouchUpInside:");
    
//    [UIView animateWithDuration:0.3 animations:^{
//        _highlightView.alpha = 0;
//    } completion:^(BOOL finished) {
//        if(finished) {
//            _highlightView.hidden = YES;
//            _highlightView.alpha = 1.0f;
//            
//            if(self.enabled) {
//                self.stepLabel.textColor = kTintColour;
//            } else {
//                self.stepLabel.textColor = RGBCOLOR(142, 142, 149);
//            }
//        }
//    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        _highlightView.alpha = 0.0f;
    }];
    
    if(self.enabled) {
        self.stepLabel.textColor = kTintColour;
    } else {
        self.stepLabel.textColor = RGBCOLOR(142, 142, 149);
    }
}

@end
