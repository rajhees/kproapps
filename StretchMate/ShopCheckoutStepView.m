//
//  ShopCheckoutStepView.m
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCheckoutStepView.h"

#define kStepNames @[ @"Login", @"Delivery", @"Payment", @"Confirm" ]

@interface ShopCheckoutStepView ()

@property (nonatomic, strong) NSMutableArray * stepViews;
@property (nonatomic, strong) NSMutableArray * stepLabels;
@property (nonatomic, strong) NSMutableArray * stepNumberViews;
@property (nonatomic, strong) NSMutableArray * stepNumberLabels;

@end

@implementation ShopCheckoutStepView

- (id)init {
    self = [super init];
    if (self) {
        
        self.stepViews = [[NSMutableArray alloc] init];
        self.stepLabels = [[NSMutableArray alloc] init];
        self.stepNumberViews = [[NSMutableArray alloc] init];
        self.stepNumberLabels = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < 4; i++) {
            
            UIView * stepView = [[UIView alloc] init];
            stepView.backgroundColor = RGBCOLOR(238, 238, 238);
            [_stepViews addObject:stepView];
            [self addSubview:stepView];
            
            UIView * stepNumberView = [[UIView alloc] init];
//            stepNumberView.backgroundColor = kTintColour;
            stepNumberView.backgroundColor = RGBCOLOR(171, 171, 171);
            stepNumberView.layer.cornerRadius = 9.0f;
            
            [stepView addSubview:stepNumberView];
            [_stepNumberViews addObject:stepNumberView];
            
            UILabel * stepNumberLabel = [[UILabel alloc] init];
            stepNumberLabel.text = [NSString stringWithFormat:@"%d", (i+1)];
            stepNumberLabel.font = [UIFont boldSystemFontOfSize:12.0f];
            stepNumberLabel.textColor = [UIColor whiteColor];
            stepNumberLabel.textAlignment = NSTextAlignmentCenter;
            [stepNumberView addSubview:stepNumberLabel];
            
            [stepNumberView addSubview:stepNumberLabel];
            [_stepNumberLabels addObject:stepNumberLabel];
            
            UILabel * stepLabel = [[UILabel alloc] init];
            stepLabel.text = kStepNames[i];
            stepLabel.font = [UIFont systemFontOfSize:12.0f];
            stepLabel.textColor = RGBCOLOR(116, 116, 116);
            
            [stepView addSubview:stepLabel];
            [_stepLabels addObject:stepLabel];
        }
        
        self.bottomBorderLayer = [CALayer layer];
        _bottomBorderLayer.backgroundColor = [RGBCOLOR(201, 201, 201) CGColor];
        [self.layer insertSublayer:_bottomBorderLayer atIndex:100];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bottomBorderLayer.frame = CGRectMake(0, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f);
    
    CGFloat stepViewWidth = self.frame.size.width / 4;
    
    int i = 0;
    for(UIView * stepView in self.stepViews) {
        stepView.frame = CGRectMake((i * stepViewWidth), 0, stepViewWidth, 33.0f);
    
        UILabel * labelForStep = _stepLabels[i];
        labelForStep.frame = CGRectMake(28.0f, 0, stepViewWidth - 26.0f, 33.0f);
        
        UILabel * numberLabel = _stepNumberLabels[i];
        numberLabel.frame = CGRectMake(0, 0, 18.0f, 18.0f);
        
        UIView * numberViewForStep = _stepNumberViews[i];
        numberViewForStep.frame = CGRectMake(4.0f, (self.frame.size.height / 2) - (18.0f / 2), 18.0f, 18.0f);
        
        i++;
    }
}

- (void)setSelectedStep:(ShopCheckoutStep)selectedStep {
    _selectedStep = selectedStep;
    
    int i = 0;
    for(UIView * stepView in _stepViews) {
        
        UIView * stepNumberView = _stepNumberViews[i];
        if(i == selectedStep) {
            stepView.backgroundColor = [UIColor whiteColor];
            stepNumberView.backgroundColor = kTintColour;
            
        } else {
            stepView.backgroundColor = RGBCOLOR(238, 238, 238);
            stepNumberView.backgroundColor = RGBCOLOR(171, 171, 171);
        }
        i++;
    }
}

@end
