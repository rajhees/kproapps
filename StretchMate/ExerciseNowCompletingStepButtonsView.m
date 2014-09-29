//
//  ExerciseNowCompletingStepButtonsView.m
//  Exersite
//
//  Created by James Eunson on 30/05/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingStepButtonsView.h"

#define kHighlightedCellGradient @[ (id)[RGBCOLOR(5, 140, 245) CGColor], (id)[RGBCOLOR(1, 93, 230) CGColor] ]

@interface ExerciseNowCompletingStepButtonsView ()

- (void)didTapPreviousButtonDown:(id)sender;
- (void)didTapPreviousButtonUp:(id)sender;
- (void)didTapNextButtonDown:(id)sender;
- (void)didTapNextButtonUp:(id)sender;

@property (nonatomic, strong) UIView * previousHighlightView;
@property (nonatomic, strong) UIView * nextHighlightView;

- (UIView*)createItemHighlightViewWithFrame:(CGRect)frame buttonFrameType:(ButtonFrameType)type;

@end

@implementation ExerciseNowCompletingStepButtonsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView * stepNavigationBackgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"exercise-blue-button-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 7, 8, 7)]];
        stepNavigationBackgroundImageView.frame = CGRectMake(0, 0, 44, 88);
        [self addSubview:stepNavigationBackgroundImageView];
        
        self.previousStepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-now-completing-prev-step-button"]];
        
        self.previousStepButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        
        self.previousHighlightView = [self createItemHighlightViewWithFrame:CGRectMake(0, 0, 44, 44) buttonFrameType:ButtonFrameTypePrevious];
        [self addSubview:_previousHighlightView];
        
        _previousStepImageView.frame = CGRectMake((_previousStepButton.frame.size.width / 2) - (_previousStepImageView.frame.size.width / 2) - 1, (_previousStepButton.frame.size.height / 2) - (_previousStepImageView.frame.size.height / 2) + 1, _previousStepImageView.frame.size.width, _previousStepImageView.frame.size.height);
        _previousStepImageView.alpha = 0.2f;
        [_previousStepButton addSubview:_previousStepImageView];
        [self addSubview:_previousStepButton];
        
        [_previousStepButton addTarget:self action:@selector(didTapPreviousButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_previousStepButton addTarget:self action:@selector(didTapPreviousButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        
        self.nextStepImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-now-completing-next-step-button"]];
        
        self.nextStepButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 45, 44, 44)];
        
        self.nextHighlightView = [self createItemHighlightViewWithFrame:CGRectMake(0, 45, 44, 44) buttonFrameType:ButtonFrameTypeNext];
        [self addSubview:_nextHighlightView];
        
        _nextStepImageView.frame = CGRectMake((_nextStepButton.frame.size.width / 2) - (_nextStepImageView.frame.size.width / 2) - 1, (_nextStepButton.frame.size.height / 2) - (_nextStepImageView.frame.size.height / 2) - 1, _nextStepImageView.frame.size.width, _nextStepImageView.frame.size.height);
        [_nextStepButton addSubview:_nextStepImageView];
        [self addSubview:_nextStepButton];
        
        [_nextStepButton addTarget:self action:@selector(didTapNextButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_nextStepButton addTarget:self action:@selector(didTapNextButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        
        CALayer * darkBorderLayer = [CALayer layer];
        [darkBorderLayer setBackgroundColor:RGBCOLOR(27, 32, 47).CGColor];
        [darkBorderLayer setFrame:CGRectMake(1, 44, 42, 1)];
        [self.layer addSublayer:darkBorderLayer];
        
        CALayer * highlightBorderLayer = [CALayer layer];
        [highlightBorderLayer setBackgroundColor:RGBCOLOR(51, 59, 86).CGColor];
        [highlightBorderLayer setFrame:CGRectMake(1, 45, 42, 1)];
        [self.layer addSublayer:highlightBorderLayer];
    }
    return self;
}

- (void)postStepChangeWithTableView:(ExerciseInstructionTableView*)tableView {
    
    NSInteger totalRows = [tableView numberOfRowsInSection:0] - 2;
    NSInteger newSelectedRowIndex = [tableView currentlySelectedIndexPath].row;
    
    if(newSelectedRowIndex == totalRows) {
        _nextStepImageView.alpha = 0.2f;
    } else {
        _nextStepImageView.alpha = 1.0f;
    }
    
    if(newSelectedRowIndex == 0) {
        _previousStepImageView.alpha = 0.2f;
    } else {
        _previousStepImageView.alpha = 1.0f;
    }
}

- (void)didTapNextButtonDown:(id)sender {
    self.nextHighlightView.alpha = 1.0f;
}
- (void)didTapNextButtonUp:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.nextHighlightView.alpha = 0.0f;
    }];
}
- (void)didTapPreviousButtonDown:(id)sender {
    self.previousHighlightView.alpha = 1.0f;
}
- (void)didTapPreviousButtonUp:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.previousHighlightView.alpha = 0.0f;
    }];
}

- (UIView*)createItemHighlightViewWithFrame:(CGRect)frame buttonFrameType:(ButtonFrameType)type {
    
    CAGradientLayer * itemHighlightLayer = [CAGradientLayer layer];
    
    [itemHighlightLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    itemHighlightLayer.actions = @{@"opacity": [NSNull null]};
    itemHighlightLayer.colors = kHighlightedCellGradient;
    
    UIBezierPath * maskPath = nil;
    if(type == ButtonFrameTypePrevious) {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, frame.size.width, frame.size.height) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6.0, 6.0)];
    } else {
        maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, frame.size.width, frame.size.height) byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(6.0, 6.0)];
    }
    
    CAShapeLayer *buttonMaskLayer = [CAShapeLayer layer];
    buttonMaskLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    buttonMaskLayer.path = maskPath.CGPath;
    itemHighlightLayer.mask = buttonMaskLayer;
    
    UIView * itemHighlightView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    [itemHighlightView.layer insertSublayer:itemHighlightLayer atIndex:0];
    itemHighlightView.alpha = 0.0f;
    itemHighlightView.userInteractionEnabled = NO;
    
    return itemHighlightView;
}

@end
