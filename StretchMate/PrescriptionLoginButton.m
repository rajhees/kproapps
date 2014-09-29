//
//  PrescriptionLoginButton.m
//  Exersite
//
//  Created by James Eunson on 4/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionLoginButton.h"

@interface PrescriptionLoginButton ()

@property (nonatomic, strong) UIView * highlightView;

- (void)didTouchUp:(id)sender;
- (void)didTouchDown:(id)sender;

@end

@implementation PrescriptionLoginButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kTintColour;
        
        self.highlightView = [[UIView alloc] init];
        _highlightView.alpha = 0.0f;
        _highlightView.userInteractionEnabled = NO;
        _highlightView.backgroundColor = RGBCOLOR(5, 140, 245);
        _highlightView.layer.cornerRadius = 4.0f;
        [self addSubview:_highlightView];
        
        self.titleTextLabel = [[UILabel alloc] init];
        _titleTextLabel.backgroundColor = [UIColor clearColor];
        _titleTextLabel.textColor = [UIColor whiteColor];
        _titleTextLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _titleTextLabel.textAlignment = NSTextAlignmentCenter;
        _titleTextLabel.text = @"Login Now";
        [self addSubview:_titleTextLabel];
        
        self.layer.cornerRadius = 4.0f;
        
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(didTouchDown:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _highlightView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _titleTextLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Private Methods
- (void)didTouchUp:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.highlightView.alpha = 0.0f;
    }];
}

- (void)didTouchDown:(id)sender {
    self.highlightView.alpha = 1.0f;
}

@end
