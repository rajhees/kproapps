//
//  ExerciseMediaView.m
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseMediaView.h"
#import "Exercise.h"
#import "NSObject+PerformBlockAfterDelay.h"
#import "PractitionerExercise.h"
#import "UIImageView+AFNetworking.h"

#define kSelectedImagePath @"selectedImagePath"

#define kStepButtonHeight 33.0f

@interface ExerciseMediaView()

@property (nonatomic, strong) NSMutableArray * imageViews;

@property (nonatomic, strong) UIToolbar * hintLabelToolbar;
@property (nonatomic, strong) UILabel * hintLabel;

- (void)pageControlPageDidChange:(id)sender;
- (void)didTapImageView:(id)sender;
- (void)didChangeMediaSegment:(id)sender;

- (void)didTapPreviousStepButton:(id)sender;
- (void)didTapNextStepButton:(id)sender;

- (void)updateFilterSegmentHighlight;

@end

@implementation ExerciseMediaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageViews = [[NSMutableArray alloc] init];
        
        self.mediaContainerTopBorder = [CALayer layer];
        _mediaContainerTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_mediaContainerTopBorder atIndex:100];
        
        self.mediaContainerBottomBorder = [CALayer layer];
        _mediaContainerBottomBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_mediaContainerBottomBorder atIndex:100];
        
        self.mediaContainerView = [[UIView alloc] init];
        _mediaContainerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_mediaContainerView];
        
        self.mediaScrollView = [[UIScrollView alloc] init];
        _mediaScrollView.delegate = self;
        _mediaScrollView.pagingEnabled = YES;
        _mediaScrollView.showsHorizontalScrollIndicator = NO;
        [_mediaContainerView addSubview:_mediaScrollView];
        
        self.mediaPageControlContainerView = [[UIView alloc] init];
        _mediaPageControlContainerView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
        _mediaPageControlContainerView.layer.cornerRadius = 4.0f;
        _mediaPageControlContainerView.alpha = 0;
        [_mediaContainerView addSubview:_mediaPageControlContainerView];
        
        self.mediaPageControl = [[StyledPageControl alloc] initWithFrame:CGRectZero];
        _mediaPageControl.pageControlStyle = PageControlStyleDefault;
        _mediaPageControl.gapWidth = 9;
        _mediaPageControl.diameter = 11;
        [_mediaPageControl setCoreNormalColor:RGBCOLOR(203, 203, 203)];
        [_mediaPageControl setCoreSelectedColor:kTintColour];
        _mediaPageControl.backgroundColor = [UIColor clearColor];
        [_mediaPageControl addTarget:self action:@selector(pageControlPageDidChange:) forControlEvents:UIControlEventValueChanged];
        [_mediaPageControlContainerView addSubview:self.mediaPageControl];
        
        self.mediaZoomButton = [[UIButton alloc] init];
        [_mediaZoomButton setImage:[UIImage imageNamed:@"shop-detail-image-zoom-button"] forState:UIControlStateNormal];
        _mediaZoomButton.userInteractionEnabled = NO;
        _mediaZoomButton.alpha = 0;
        [_mediaContainerView addSubview:_mediaZoomButton];
        
        self.mediaContainerSegmentedControlBorder = [CALayer layer];
        _mediaContainerSegmentedControlBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [_mediaContainerView.layer insertSublayer:_mediaContainerSegmentedControlBorder atIndex:100];
        
        self.mediaSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Video", @"Images" ]];
        _mediaSegmentedControl.tintColor = kTintColour;
        [_mediaSegmentedControl addTarget:self action:@selector(didChangeMediaSegment:) forControlEvents:UIControlEventValueChanged];
        _mediaSegmentedControl.selectedSegmentIndex = 0;
        [_mediaContainerView addSubview:_mediaSegmentedControl];
        
        self.noImageAvailableImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-no-image-available-ios7"]];
        _noImageAvailableImageView.hidden = YES;
        [_mediaContainerView addSubview:_noImageAvailableImageView];
        
        self.noImageAvailableLabel = [[UILabel alloc] init];
        _noImageAvailableLabel.textAlignment = NSTextAlignmentCenter;
        _noImageAvailableLabel.text = @"No image available for this exercise";
        _noImageAvailableLabel.textColor = [UIColor grayColor];
        _noImageAvailableLabel.font = [UIFont systemFontOfSize:14.0f];
        _noImageAvailableLabel.numberOfLines = 0;
        _noImageAvailableLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _noImageAvailableLabel.backgroundColor = [UIColor clearColor];
        _noImageAvailableLabel.hidden = YES;
        [_mediaContainerView addSubview:_noImageAvailableLabel];
        
        // Step buttons only visible if mode == ExerciseMediaViewTypeNowCompletingSteps
        self.previousStepButton = [[ExerciseNowCompletingStepButton alloc] initWithType:ExerciseNowCompletingStepButtonTypePrevious];
        [_previousStepButton addTarget:self action:@selector(didTapPreviousStepButton:) forControlEvents:UIControlEventTouchUpInside];
        _previousStepButton.hidden = YES;
        [self setPreviousStepButtonEnabled:NO];
        [_mediaContainerView addSubview:_previousStepButton];
        
        self.nextStepButton = [[ExerciseNowCompletingStepButton alloc] initWithType:ExerciseNowCompletingStepButtonTypeNext];
        [_nextStepButton addTarget:self action:@selector(didTapNextStepButton:) forControlEvents:UIControlEventTouchUpInside];
        _nextStepButton.hidden = YES;
        [_mediaContainerView addSubview:_nextStepButton];
        
        if(![[AppConfig sharedConfig] exerciseNowCompletingSwipeTipActionPerformed]) {
            
            self.hintLabelToolbar = [[UIToolbar alloc] init];
            _hintLabelToolbar.translucent = YES;
            _hintLabelToolbar.barTintColor = [UIColor blackColor];
            
            self.hintLabel = [[UILabel alloc] init];
            _hintLabel.text = @"Swipe video to view images.";
            _hintLabel.textColor = [UIColor whiteColor];
            _hintLabel.backgroundColor = [UIColor clearColor];
            _hintLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            _hintLabel.textAlignment = NSTextAlignmentCenter;
            _hintLabel.userInteractionEnabled = NO;
            [_hintLabelToolbar addSubview:_hintLabel];
            
            [_mediaContainerView addSubview:_hintLabelToolbar];
        }
        
        [self addSubview:_mediaContainerView];
        
        [self performBlock:^{
            [self updateFilterSegmentHighlight];
        } afterDelay:0.1];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _mediaContainerView.frame = CGRectMake(0, _mediaContainerTopBorder.frame.origin.y + _mediaContainerTopBorder.frame.size.height, self.frame.size.width, self.frame.size.height);
    _mediaScrollView.frame = CGRectMake(0, 8.0f, self.frame.size.width, kExerciseMediaScrollViewHeight);
    _mediaScrollView.backgroundColor = [UIColor whiteColor];
    
    _mediaContainerTopBorder.frame = CGRectMake(0, 0, self.frame.size.width, 1.0f);
    _mediaContainerBottomBorder.frame = CGRectMake(0, _mediaContainerView.frame.origin.y + _mediaContainerView.frame.size.height, self.frame.size.width, 1.0f);
    
    CGFloat pageControlWidth = (([self.imageViews count] + 1) * 24.0f) + 16.0f;
    _mediaPageControlContainerView.frame = CGRectMake((self.frame.size.width / 2) - (pageControlWidth / 2), self.frame.size.height - 60.0f - 12.0f, pageControlWidth, 20.0f);
    _mediaPageControl.frame = CGRectMake(8.0f, 0, pageControlWidth - 16.0f, 20.0f);
    _mediaZoomButton.frame = CGRectMake(_mediaContainerView.frame.size.width - 35.0f - 8.0f, self.frame.size.height - 60.0f - 28.0f, 35.0f, 36.0f);
    
    if(_playerController) {
        _playerController.view.frame = CGRectMake(0, 0, self.frame.size.width, _mediaScrollView.frame.size.height);
    }
    
    int i = 0;
    for(UIImageView * imageView in self.imageViews) {
        
        // If item is a stock exercise and has a video associated, offset all images by 1 width of screen
        if([self.selectedExercise isKindOfClass:[Exercise class]] && self.playerController) {
            imageView.frame = CGRectMake(self.frame.size.width * (i + 1), 0, self.frame.size.width, _mediaScrollView.frame.size.height);
        } else {
            imageView.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, _mediaScrollView.frame.size.height);
        }
        i++;
    }
    if([self.selectedExercise isKindOfClass:[Exercise class]] && self.playerController) {
        self.mediaScrollView.contentSize = CGSizeMake((([self.imageViews count] + 1) * self.frame.size.width), self.mediaScrollView.frame.size.height);
    } else {
        self.mediaScrollView.contentSize = CGSizeMake(self.frame.size.width, self.mediaScrollView.frame.size.height);
    }
    
    if(self.type == ExerciseMediaViewTypeNormal) {
        
        _mediaSegmentedControl.frame = CGRectMake(40, _mediaContainerView.frame.size.height - 30.0f - 6.0f, self.frame.size.width - 80.0f, 30.0f);
        _mediaContainerSegmentedControlBorder.frame = CGRectMake(0, kExerciseMediaContainerHeight - 44.0f, self.frame.size.width, 1.0f);
        
    } else {
        
        _previousStepButton.frame = CGRectMake(0, self.frame.size.height - kStepButtonHeight, self.frame.size.width / 2, kStepButtonHeight);
        _nextStepButton.frame = CGRectMake((self.frame.size.width / 2), self.frame.size.height - kStepButtonHeight, self.frame.size.width / 2, kStepButtonHeight);
        
        if(_hintLabelToolbar) {
            _hintLabelToolbar.frame = CGRectMake(0, self.frame.size.height - kStepButtonHeight - 44.0f, self.frame.size.width, 44.0f);
            _hintLabel.frame = CGRectMake(0, 0, self.frame.size.width, 44.0f);
        }
    }
    
    CGSize sizeForNoImageAvailableLabel = [_noImageAvailableLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(_mediaContainerView.frame.size.width - 100.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat startingPoint = -1;
    if(self.type == ExerciseMediaViewTypeNormal) {
        startingPoint = (_mediaContainerView.frame.size.height / 2) - ((sizeForNoImageAvailableLabel.height + _noImageAvailableImageView.frame.size.height) / 2);
    } else {
        startingPoint = (_mediaContainerView.frame.size.height / 2) - ((sizeForNoImageAvailableLabel.height + _noImageAvailableImageView.frame.size.height) / 2) - 20.0f;
    }

    _noImageAvailableImageView.frame = CGRectMake((_mediaContainerView.frame.size.width / 2) - (_noImageAvailableImageView.frame.size.width / 2), startingPoint, _noImageAvailableImageView.frame.size.width, _noImageAvailableImageView.frame.size.height);
    
    _noImageAvailableLabel.frame = CGRectMake((_mediaContainerView.frame.size.width / 2) - (sizeForNoImageAvailableLabel.width / 2), _noImageAvailableImageView.frame.origin.y + _noImageAvailableImageView.frame.size.height + 10.0f, sizeForNoImageAvailableLabel.width, sizeForNoImageAvailableLabel.height);
}

- (void)updateMediaScrollViewContentOffset {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    [self performBlock:^{
        
//        NSLog(@"current page: %d, calculated offset: %f", self.mediaPageControl.currentPage, self.mediaPageControl.currentPage * screenWidth);
        [self.mediaScrollView setContentOffset:CGPointMake(self.mediaPageControl.currentPage * screenWidth, 0) animated:NO];
        
    } afterDelay:0.1];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(scrollView == self.mediaScrollView) {
        int pageNumber = (scrollView.contentOffset.x / self.frame.size.width);
        self.mediaPageControl.currentPage = pageNumber;
        
        [self updateNavigationVisibilityForPage:pageNumber];
        
        if(_hintLabelToolbar) {
            
            [[AppConfig sharedConfig] setBool:YES forKey:kExerciseNowCompletingSwipeTipActionPerformed];
            
            [UIView animateWithDuration:0.5 animations:^{
                _hintLabelToolbar.alpha = 0.f;
            } completion:^(BOOL finished) {
                if(finished) {
                    [_hintLabelToolbar removeFromSuperview];
                    
                }
            }];
        }
    }
}

#pragma mark - Property Override
- (void)setSelectedExercise:(id)selectedExercise {
    _selectedExercise = selectedExercise;
    
    if([selectedExercise isKindOfClass:[Exercise class]]) {

        Exercise * databaseExercise = (Exercise*)selectedExercise;
        
        for(UIImage * image in [databaseExercise getImages]) {
            
            UIImageView * exerciseImageView = [[UIImageView alloc] initWithImage:image];
            exerciseImageView.contentMode = UIViewContentModeScaleAspectFill;
            
            UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
            exerciseImageView.userInteractionEnabled = YES;
            [exerciseImageView addGestureRecognizer:tapGestureRecognizer];
            
            [self.imageViews addObject:exerciseImageView];
            [self.mediaScrollView addSubview:exerciseImageView];
        }
        
        NSString * videoPath = [databaseExercise getVideoFilePath];
        
        if(videoPath) {
            
            _mediaPageControl.numberOfPages = ([self.imageViews count] + 1);
            
            self.playerController = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL fileURLWithPath:videoPath]];
            [_playerController setScalingMode:MPMovieScalingModeAspectFit];
            _playerController.controlStyle = MPMovieControlStyleEmbedded;
            _playerController.fullscreen = NO;
            _playerController.repeatMode = MPMovieRepeatModeOne;
            
            if(self.type == ExerciseMediaViewTypeNormal) {
                [_playerController prepareToPlay];
                _playerController.shouldAutoplay = YES;
            }
            
            [self.mediaScrollView addSubview: _playerController.view];
            [self.mediaScrollView bringSubviewToFront:_playerController.view];
            
        } else { // No video, don't account for it in page number
            _mediaPageControl.numberOfPages = [self.imageViews count];
        }
        
    } else {
        
        PractitionerExercise * practitionerExercise = (PractitionerExercise*)selectedExercise;
        self.mediaSegmentedControl.hidden = YES;
        
        if(practitionerExercise.image == nil || [practitionerExercise.image rangeOfString:@"missing.png"].location != NSNotFound) {
            
            _noImageAvailableLabel.hidden = NO;
            _noImageAvailableImageView.hidden = NO;
            return;
        }
        
        UIImageView * exerciseImageView = [[UIImageView alloc] init];
        exerciseImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
        exerciseImageView.userInteractionEnabled = YES;
        [exerciseImageView addGestureRecognizer:tapGestureRecognizer];
        
        [self.imageViews addObject:exerciseImageView];
        [self.mediaScrollView addSubview:exerciseImageView];
        
        _mediaPageControl.numberOfPages = 1;
        
        NSString * practitionerExerciseImage = practitionerExercise.image;
        
        __block ExerciseMediaView * blockSelf = self;
        __block UIImageView * blockExerciseImageView = exerciseImageView;
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:practitionerExercise.image]];
        [exerciseImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            blockExerciseImageView.image = image;
            [blockExerciseImageView sizeToFit];
            
            [blockSelf setNeedsLayout];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//            NSLog(@"Failed to load image for ExerciseMediaView");
            
            _noImageAvailableLabel.hidden = NO;
            _noImageAvailableImageView.hidden = NO;
        }];
    }
}

- (void)setType:(ExerciseMediaViewType)type {
    _type = type;
    
    if(type == ExerciseMediaViewTypeNormal) {
        
        self.mediaSegmentedControl.hidden = NO;
        self.mediaContainerSegmentedControlBorder.hidden = NO;
        
        self.previousStepButton.hidden = YES;
        self.nextStepButton.hidden = YES;
        self.hintLabel.hidden = YES;
        
    } else if(type == ExerciseMediaViewTypeNowCompletingSteps) {
        
        self.mediaSegmentedControl.hidden = YES;
        self.mediaContainerSegmentedControlBorder.hidden = YES;
        
        self.previousStepButton.hidden = NO;
        self.nextStepButton.hidden = NO;
        self.hintLabel.hidden = NO;
    }
}

// Violates OO principles by coupling this with the step view, whatever, deadline
// Plus the code duplication here is not good
- (void)setPreviousStepButtonEnabled:(BOOL)previousStepButtonEnabled {
    _previousStepButton.enabled = previousStepButtonEnabled;
    
    if(previousStepButtonEnabled) {
        _previousStepButton.stepLabel.textColor = kTintColour;
        _previousStepButton.backgroundColor = [UIColor clearColor];
        _previousStepButton.stepImageView.hidden = NO;
        _previousStepButton.disabledStepImageView.hidden = YES;
        
    } else {
        
        _previousStepButton.stepLabel.textColor = RGBCOLOR(142, 142, 149);
        _previousStepButton.backgroundColor = RGBCOLOR(238, 238, 238);
        _previousStepButton.stepImageView.hidden = YES;
        _previousStepButton.disabledStepImageView.hidden = NO;
    }
}

- (void)setNextStepButtonEnabled:(BOOL)nextStepButtonEnabled {
    _nextStepButton.enabled = nextStepButtonEnabled;
    
    if(nextStepButtonEnabled) {
        _nextStepButton.stepLabel.textColor = kTintColour;
        _nextStepButton.backgroundColor = [UIColor clearColor];
        _nextStepButton.stepImageView.hidden = NO;
        _nextStepButton.disabledStepImageView.hidden = YES;
        
    } else {
        
        _nextStepButton.stepLabel.textColor = RGBCOLOR(142, 142, 149);
        _nextStepButton.backgroundColor = RGBCOLOR(238, 238, 238);
        _nextStepButton.stepImageView.hidden = YES;
        _nextStepButton.disabledStepImageView.hidden = NO;
    }
}

#pragma mark - Private Methods
- (void)pageControlPageDidChange:(id)sender {
//    NSLog(@"pageControlPageDidChange:");
    
    StyledPageControl * pageControl = (StyledPageControl*)sender;
    [self.mediaScrollView setContentOffset:CGPointMake(self.frame.size.width * pageControl.currentPage, 0) animated:YES];
    
    [self updateNavigationVisibilityForPage:pageControl.currentPage];
}

- (void)updateNavigationVisibilityForPage:(NSInteger)pageNumber {
    
    if(pageNumber > 0 && _mediaZoomButton.alpha == 0) {
        
        if([self.selectedExercise isKindOfClass:[Exercise class]]) {
         
            [UIView animateWithDuration:0.3 animations:^{
                _mediaZoomButton.alpha = 1.0f;
                _mediaPageControlContainerView.alpha = 1.0f;
            }];
            
            self.mediaSegmentedControl.selectedSegmentIndex = 1;
            [self updateFilterSegmentHighlight];
            
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                _mediaZoomButton.alpha = 1.0f;
            }];
        }
        
    } else if(pageNumber == 0 && _mediaZoomButton.alpha > 0) {
        
        if([self.selectedExercise isKindOfClass:[Exercise class]]) {
         
            [UIView animateWithDuration:0.3 animations:^{
                _mediaZoomButton.alpha = 0.0f;
                _mediaPageControlContainerView.alpha = 0.0f;
            }];
            
            self.mediaSegmentedControl.selectedSegmentIndex = 0;
            [self updateFilterSegmentHighlight];
            
        } else {
            
            [UIView animateWithDuration:0.3 animations:^{
                _mediaZoomButton.alpha = 0.0f;
            }];
        }
    }
}

- (void)updateFilterSegmentHighlight {
    
    // Modify selected segment color
    for (int i=0; i < [self.mediaSegmentedControl.subviews count]; i++) {
        if ([[self.mediaSegmentedControl.subviews objectAtIndex:i] isSelected] ) {
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                [[self.mediaSegmentedControl.subviews objectAtIndex:i] setTintColor:kLightTintColour];
            } else {
                [[self.mediaSegmentedControl.subviews objectAtIndex:i] setTintColor:RGBCOLOR(216, 116, 36)];
            }
        } else {
            [[self.mediaSegmentedControl.subviews objectAtIndex:i] setTintColor:[UIColor lightGrayColor]];
        }
    }
}

- (void)didTapImageView:(id)sender {
    
    UITapGestureRecognizer * tapGestureRecognizer = (UITapGestureRecognizer*)sender;
    UIImageView * imageView = (UIImageView*)[tapGestureRecognizer view];
    
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
     
        Exercise * databaseExercise = (Exercise*)_selectedExercise;
        NSInteger indexOfSelectedImageView = [self.imageViews indexOfObject:imageView];
        
        if(indexOfSelectedImageView != NSNotFound) {
            NSArray * imagePaths = [databaseExercise getImagePaths];
            NSString * pathForImage = imagePaths[indexOfSelectedImageView];
            
            if([self.delegate respondsToSelector:@selector(exerciseMediaView:didTapImageViewWithParameters:)]) {
                [self.delegate performSelector:@selector(exerciseMediaView:didTapImageViewWithParameters:) withObject:self withObject:@{ kSelectedImagePath : pathForImage }];
            }
        }
        
    } else {

        NSString * imagePath = ((PractitionerExercise*)self.selectedExercise).image;
        
        // Check if an image is actually available
        if(imagePath == nil || [imagePath rangeOfString:@"missing.png"].location != NSNotFound) {
            return;
        }
        
        if([self.delegate respondsToSelector:@selector(exerciseMediaView:didTapImageViewWithParameters:)]) {
            [self.delegate performSelector:@selector(exerciseMediaView:didTapImageViewWithParameters:) withObject:self withObject:@{ kSelectedImagePath : imagePath }];
        }
    }
}

- (void)didChangeMediaSegment:(id)sender {
//    NSLog(@"didChangeMediaSegment");
    
    UISegmentedControl * control = (UISegmentedControl*)sender;
    
    if(control.selectedSegmentIndex == 0) {
        [self.mediaScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.mediaPageControl.currentPage = 0;
    } else {
        [self.mediaScrollView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:YES];
        self.mediaPageControl.currentPage = 1;
    }
    
    [self updateNavigationVisibilityForPage:self.mediaPageControl.currentPage];
    [self updateFilterSegmentHighlight];
}

- (void)didTapPreviousStepButton:(id)sender {
//    NSLog(@"didTapPreviousStepButton:");
    
    if([self.delegate respondsToSelector:@selector(exerciseMediaView:didTapDirectionButtonWithDirection:)]) {
        [self.delegate performSelector:@selector(exerciseMediaView:didTapDirectionButtonWithDirection:) withObject:self withObject:@(ExerciseMediaViewDirectionPrevious)];
    }
}

- (void)didTapNextStepButton:(id)sender {
//    NSLog(@"didTapNextStepButton:");
    
    if([self.delegate respondsToSelector:@selector(exerciseMediaView:didTapDirectionButtonWithDirection:)]) {
        [self.delegate performSelector:@selector(exerciseMediaView:didTapDirectionButtonWithDirection:) withObject:self withObject:@(ExerciseMediaViewDirectionNext)];
    }
}

@end
