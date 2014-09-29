//
//  TutorialToolbar.m
//  Exersite
//
//  Created by James Eunson on 7/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "TutorialToolbar.h"

@interface TutorialToolbar ()
- (void)didTapNextButton:(id)sender;
- (void)didTapPreviousButton:(id)sender;

@property (nonatomic, strong) UIView * backgroundColorView;

@end

@implementation TutorialToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.translucent = NO;
        self.userInteractionEnabled = YES;
        
        self.backgroundColorView = [[UIView alloc] init];
        _backgroundColorView.backgroundColor = RGBCOLOR(238, 238, 238);
        [self addSubview:_backgroundColorView];
        
        self.previousButton = [[TutorialDirectionButton alloc] initWithType:TutorialDirectionButtonTypePrev];
        [_previousButton addTarget:self action:@selector(didTapPreviousButton:) forControlEvents:UIControlEventTouchUpInside];
        _previousButton.alpha = 0.f;
        [self addSubview:_previousButton];
        
        self.nextButton = [[TutorialDirectionButton alloc] initWithType:TutorialDirectionButtonTypeNext];
        [_nextButton addTarget:self action:@selector(didTapNextButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextButton];
        
        self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.pageControlStyle = PageControlStyleDefault;
        _pageControl.gapWidth = 9;
        _pageControl.diameter = 11;
        [_pageControl setCoreNormalColor:RGBCOLOR(203, 203, 203)];
        [_pageControl setCoreSelectedColor:kTintColour];
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = 6;
        _pageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageControl];
        
        self.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColorView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.previousButton.frame = CGRectMake(8.0f, 6.0f, 60.0f, self.frame.size.height - 12.0f);
    self.nextButton.frame = CGRectMake(self.frame.size.width - 8.0f - 60.0f, 6.0f, 60.0f, self.frame.size.height - 12.0f);
    
    self.pageControl.frame = CGRectMake(_previousButton.frame.origin.y + _previousButton.frame.size.width + 8.0f, 8.0f, self.frame.size.width - (60.0f * 2) - 32.0f, self.frame.size.height - 16.0f);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0f);
}

#pragma mark - Private Methods
- (void)didTapNextButton:(id)sender {
    if([self.tutorialToolbarDelegate respondsToSelector:@selector(tutorialToolbar:didTapNextPageButton:)]) {
        [self.tutorialToolbarDelegate performSelector:@selector(tutorialToolbar:didTapNextPageButton:) withObject:self withObject:sender];
    }
}

- (void)didTapPreviousButton:(id)sender {
    if([self.tutorialToolbarDelegate respondsToSelector:@selector(tutorialToolbar:didTapPreviousPageButton:)]) {
        [self.tutorialToolbarDelegate performSelector:@selector(tutorialToolbar:didTapPreviousPageButton:) withObject:self withObject:sender];
    }
}

@end
