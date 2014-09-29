//
//  ExerciseMediaSelectorView.m
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseSelectorView.h"
#import "ExerciseMediaSelectButton.h"

#define kXOffsetFirst 12.0f
#define kXOffsetSecond 152.0f

@interface ExerciseSelectorView()
- (void)didTapButton:(id)sender;
- (void)initializeContainer;
- (void)initializeButtonsWithOptions:(NSDictionary*)options;

@property (nonatomic, strong) NSArray * selectorButtons;

@end

@implementation ExerciseSelectorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initializeContainer];
        [self initializeButtonsWithOptions:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame options:(NSDictionary*)options {
    
    self = [self initWithFrame:frame];
    if(self) {
        
        [self initializeContainer];
        [self initializeButtonsWithOptions:options];
    }
    return self;
}

- (void)initializeContainer {
    
    self.selectedButton = 0;
    
    UIImageView * mediaContainerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-media-selector-bg"]];
    mediaContainerImageView.frame = CGRectMake(1, 0, mediaContainerImageView.frame.size.width, mediaContainerImageView.frame.size.height);
    [self addSubview:mediaContainerImageView];
    
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-media-button-bg"]];
    _selectedBackgroundView.frame = CGRectMake(12, 4, _selectedBackgroundView.frame.size.width, _selectedBackgroundView.frame.size.height);
    [self addSubview:self.selectedBackgroundView];
}

- (void)initializeButtonsWithOptions:(NSDictionary*)options {
    
    ExerciseMediaButtonType firstButtonType = (options ? ExerciseMediaButtonTypeCustom : ExerciseMediaButtonTypeImages);
    ExerciseMediaButtonType secondButtonType = (options ? ExerciseMediaButtonTypeCustom : ExerciseMediaButtonTypeVideo);
    
    ExerciseMediaSelectButton * firstButton = [[ExerciseMediaSelectButton alloc] initWithFrame:CGRectMake(12, 4.0f, 130, 27) andType:firstButtonType];
    [firstButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:firstButton];
    
    ExerciseMediaSelectButton * secondButton = [[ExerciseMediaSelectButton alloc] initWithFrame:CGRectMake(152, 4.0f, 130, 27) andType:secondButtonType];
    [secondButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:secondButton];
    
    if(options) { // Assumed there are both an array of "titles" and "images" both with two elements
        
        firstButton.buttonView.titleLabel.text = options[@"titles"][0];
        firstButton.buttonView.iconView.image = [UIImage imageNamed:options[@"images"][0]];
        [firstButton.buttonView.iconView sizeToFit];
        
        secondButton.buttonView.titleLabel.text = options[@"titles"][1];
        secondButton.buttonView.iconView.image = [UIImage imageNamed:options[@"images"][1]];
        [secondButton.buttonView.iconView sizeToFit];
    }
    
    self.selectorButtons = @[ firstButton, secondButton ];
}

- (void)didTapButton:(id)sender {
    
    ExerciseMediaSelectButton * button = (ExerciseMediaSelectButton*)sender;
    NSInteger tappedButtonIndex = [self.selectorButtons indexOfObject:button];
    
    if(self.selectedButton == [self.selectorButtons indexOfObject:button]) return;
    
    self.selectedButton = tappedButtonIndex;
}

- (void)setSelectedButton:(NSInteger)selectedButton {
    
    _selectedButton = selectedButton;
    
    CGFloat targetOffset = 0;
    if(_selectedButton == 0) {
        targetOffset = kXOffsetFirst;
    } else {
        targetOffset = kXOffsetSecond;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.selectedBackgroundView.frame = CGRectMake(targetOffset, 4, _selectedBackgroundView.frame.size.width, _selectedBackgroundView.frame.size.height);
    }];
    
    if([self.delegate respondsToSelector:@selector(exerciseSelectorView:didChangeSelection:)]) {
        [self.delegate performSelector:@selector(exerciseSelectorView:didChangeSelection:) withObject:self withObject:@(self.selectedButton)];
    }    
}

- (void)setVideoEnabled:(BOOL)videoEnabled {
    _videoEnabled = videoEnabled;
    
    UIButton * videoButton = self.selectorButtons[1];
    [videoButton setEnabled:videoEnabled];
    
    if(videoEnabled) {
        videoButton.alpha = 1.0f;
    } else {
        videoButton.alpha = 0.3f;
    }
}

@end
