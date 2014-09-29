//
//  TutorialDirectionButton.m
//  Exersite
//
//  Created by James Eunson on 7/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "TutorialDirectionButton.h"

@interface TutorialDirectionButton ()

@property (nonatomic, strong) UIView * highlightView;

- (void)didTouchUp:(id)sender;
- (void)didTouchDown:(id)sender;

@end

@implementation TutorialDirectionButton

- (id)initWithType:(TutorialDirectionButtonType)type {
    self = [super init];
    if(self) {
        
        self.highlightView = [[UIView alloc] init];
        _highlightView.alpha = 0.0f;
        _highlightView.userInteractionEnabled = NO;
        _highlightView.backgroundColor = RGBCOLOR(5, 140, 245);
        _highlightView.layer.cornerRadius = 4.0f;
        [self addSubview:_highlightView];
        
        self.directionTitleLabel = [[UILabel alloc] init];
        _directionTitleLabel.textColor = [UIColor whiteColor];
        _directionTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _directionTitleLabel.backgroundColor = [UIColor clearColor];
        _directionTitleLabel.textAlignment = NSTextAlignmentCenter;
        _directionTitleLabel.userInteractionEnabled = NO;
        [self addSubview:_directionTitleLabel];
        
        self.layer.cornerRadius = 4.0f;
        
        self.type = type;
        
        [self addTarget:self action:@selector(didTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

- (void)setType:(TutorialDirectionButtonType)type {
    _type = type;

    if(type == TutorialDirectionButtonTypePrev) {
        
        self.directionTitleLabel.text = @"Prev";
        self.backgroundColor = RGBCOLOR(165, 166, 171);
        
    } else {
        
        self.directionTitleLabel.text = @"Next";
        self.backgroundColor = kTintColour;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.highlightView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.directionTitleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Private Methods
- (void)didTouchDown:(id)sender {
    
    _highlightView.alpha = 1.0f;
}

- (void)didTouchUp:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        _highlightView.alpha = 0.0f;
    }];
}


@end
