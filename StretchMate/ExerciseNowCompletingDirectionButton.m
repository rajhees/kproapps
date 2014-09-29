//
//  ExerciseNowCompletingDirectionButton.m
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingDirectionButton.h"

@interface ExerciseNowCompletingDirectionButton ()

- (void)didTouchDown:(id)sender;
- (void)didTouchUp:(id)sender;

@property (nonatomic, strong) UIView * highlightView;

@end

@implementation ExerciseNowCompletingDirectionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [RGBCOLOR(180, 180, 180) CGColor];
        self.layer.cornerRadius = 4.0f;
        
        self.highlightView = [[UIView alloc] init];
        _highlightView.alpha = 0.0f;
        _highlightView.userInteractionEnabled = NO;
        _highlightView.backgroundColor = RGBCOLOR(5, 140, 245);
        _highlightView.layer.cornerRadius = 4.0f;
        [self addSubview:_highlightView];
        
        self.directionImageView = [[UIImageView alloc] init];
        _directionImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_directionImageView];
        
        self.disabledDirectionImageView = [[UIImageView alloc] init];
        _disabledDirectionImageView.contentMode = UIViewContentModeCenter;
        _disabledDirectionImageView.hidden = YES;
        [self addSubview:_disabledDirectionImageView];
        
        [self addTarget:self action:@selector(didTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.directionImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.disabledDirectionImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    _highlightView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Property Override
- (void)setType:(ExerciseNowCompletingDirectionButtonType)type {
    _type = type;
    
    if(type == ExerciseNowCompletingDirectionButtonTypePrevious) {
        self.directionImageView.image = [UIImage imageNamed:@"exercise-now-completing-previous-exercise-icon-ios7"];
        self.disabledDirectionImageView.image = [UIImage imageNamed:@"exercise-now-completing-previous-exercise-icon-disabled-ios7"];
        
    } else if(type == ExerciseNowCompletingDirectionButtonTypeNext) {
        self.directionImageView.image = [UIImage imageNamed:@"exercise-now-completing-next-exercise-icon-ios7"];
        self.disabledDirectionImageView.image = [UIImage imageNamed:@"exercise-now-completing-next-exercise-icon-disabled-ios7"];
    }
    
    [self.directionImageView sizeToFit];
    [self.disabledDirectionImageView sizeToFit];
}

- (void)setDirectionButtonEnabled:(BOOL)directionButtonEnabled {
    _directionButtonEnabled = directionButtonEnabled;
    
//    self.enabled = directionButtonEnabled;
    
    if(directionButtonEnabled) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.directionImageView.hidden = NO;
        self.disabledDirectionImageView.hidden = YES;
        
    } else {
        
        self.backgroundColor = RGBCOLOR(238, 238, 238);
        self.directionImageView.hidden = YES;
        self.disabledDirectionImageView.hidden = NO;
    }
}

#pragma mark - Private Methods
- (void)didTouchDown:(id)sender {
//    NSLog(@"didTouchDown");
    
    if(self.directionButtonEnabled) {
        _highlightView.alpha = 1.0f;
    }
}

- (void)didTouchUp:(id)sender {
//    NSLog(@"didTouchUp");
    
    if(self.directionButtonEnabled) {
        [UIView animateWithDuration:0.5f animations:^{
            _highlightView.alpha = 0.0f;
        }];
    }
}

@end
