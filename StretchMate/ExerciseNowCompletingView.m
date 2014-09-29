//
//  ExerciseNowCompletingView.m
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingView.h"
#import "Exercise.h"
#import "ExerciseNowCompletingToolbar.h"
#import "PractitionerExercise.h"

#define kSubtitleTemplate @"Approximate completion time: %@"

@interface ExerciseNowCompletingView ()
- (void)updateNavigationButtonsWithIndexPath:(NSIndexPath*)destinationIndexPath;
@end

@implementation ExerciseNowCompletingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.type = ExerciseNowCompletingViewTypeSingle;
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_titleLabel];
        
        self.completionSubtitleLabel = [[UILabel alloc] init];
        _completionSubtitleLabel.textColor = RGBCOLOR(142, 142, 149);
        _completionSubtitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _completionSubtitleLabel.backgroundColor = [UIColor clearColor];
        _completionSubtitleLabel.numberOfLines = 0;
        _completionSubtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_completionSubtitleLabel];
        
        self.mediaView = [[ExerciseMediaView alloc] init];
        _mediaView.type = ExerciseMediaViewTypeNowCompletingSteps;
        _mediaView.delegate = self;
        [self addSubview:_mediaView];
        
        self.instructionsTableViewTopBorder = [CALayer layer];
        _instructionsTableViewTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_instructionsTableViewTopBorder atIndex:100];
        
        self.instructionsTableView = [[ExerciseInstructionTableView alloc] initWithFrame:CGRectZero selectedExercise:self.selectedExercise mode:ExerciseInstructionTableViewModeCompleting];
        _instructionsTableView.rowChangeDelegate = self;
        _instructionsTableView.scrollEnabled = NO;
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            _instructionsTableView.separatorInset = UIEdgeInsetsZero;
        }
        [self addSubview:_instructionsTableView];
        
        if(![[AppConfig sharedConfig] exerciseNowCompletingStartFinishTipActionPerformed]) {
            
            self.startFinishHintToolbar = [[UIToolbar alloc] init];
            _startFinishHintToolbar.translucent = YES;
            _startFinishHintToolbar.barTintColor = [UIColor blackColor];
            
            self.startFinishHintLabel = [[UILabel alloc] init];
            _startFinishHintLabel.textColor = [UIColor whiteColor];
            _startFinishHintLabel.backgroundColor = [UIColor clearColor];
            _startFinishHintLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            _startFinishHintLabel.textAlignment = NSTextAlignmentCenter;
            _startFinishHintLabel.userInteractionEnabled = NO;
            _startFinishHintLabel.text = @"Press 'Start' to begin performing this exercise, and tap 'I'm Finished' when you're done.";
            _startFinishHintLabel.numberOfLines = 0;
            _startFinishHintLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [_startFinishHintToolbar addSubview:_startFinishHintLabel];
            
            [self addSubview:_startFinishHintToolbar];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat mediaViewStartPoint = 0;
    if(self.type == ExerciseNowCompletingViewTypeSingle) {
        
        CGSize sizeForTitleLabel = [_titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        self.titleLabel.frame = CGRectMake(8.0f, 8.0f, sizeForTitleLabel.width, sizeForTitleLabel.height);
        
        CGSize sizeForSubtitleLabel = [_completionSubtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        self.completionSubtitleLabel.frame = CGRectMake(8.0f, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, sizeForSubtitleLabel.width, sizeForSubtitleLabel.height);
        
        mediaViewStartPoint = _completionSubtitleLabel.frame.origin.y + _completionSubtitleLabel.frame.size.height + 19.0f;
        
    } else {
        mediaViewStartPoint = 8.0f;
    }
    
    _mediaView.frame = CGRectMake(0, mediaViewStartPoint, self.frame.size.width, kExerciseMediaNowCompletingContainerHeight);
    
    _instructionsTableViewTopBorder.frame = CGRectMake(0, _mediaView.frame.origin.y + _mediaView.frame.size.height + 8.0f, self.frame.size.width, 1.0f);
    _instructionsTableView.frame = CGRectMake(0, _mediaView.frame.origin.y + _mediaView.frame.size.height + 9.0f, self.frame.size.width, self.frame.size.height - (_mediaView.frame.origin.y + _mediaView.frame.size.height + 8.0f));
    
    CGSize sizeOfStartFinishLabel = [_startFinishHintLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat heightForStartFinishHintLabel = sizeOfStartFinishLabel.height + 16.0f;
    
    _startFinishHintToolbar.frame = CGRectMake(0, self.frame.size.height - kNowCompletingToolbarMultipleExercisesHeight - heightForStartFinishHintLabel, self.frame.size.width, heightForStartFinishHintLabel);
    _startFinishHintLabel.frame = CGRectMake(8.0f, 0, self.frame.size.width - 16.0f, heightForStartFinishHintLabel);
}

#pragma mark - Property Override
- (void)setSelectedExercise:(id)selectedExercise {
    _selectedExercise = selectedExercise;
    
    Exercise * databaseExercise = (Exercise*)selectedExercise;
    self.titleLabel.text = databaseExercise.nameBasic;
    
    // Initialise minutes and seconds readout with starting time
    NSInteger totalSeconds = [((Exercise*)self.selectedExercise).seconds integerValue];
    int seconds = (totalSeconds % 60);
    NSString * secondsString = nil;
    
    if(seconds < 10) {
        secondsString = [NSString stringWithFormat:@"0%d", (totalSeconds % 60)];
    } else {
        secondsString = [NSString stringWithFormat:@"%d", (totalSeconds % 60)];
    }
    NSString * minutesString = [NSString stringWithFormat:@"%d", (int)(floorf((float)totalSeconds / 60.0f))];
    NSString * completionTimeString = [NSString stringWithFormat:@"%@:%@", minutesString, secondsString];
    self.completionSubtitleLabel.text = [NSString stringWithFormat:kSubtitleTemplate, completionTimeString];
    
    _mediaView.selectedExercise = databaseExercise;
    
    self.instructionsTableView.selectedExercise = databaseExercise;
    [self.instructionsTableView reloadData];
    
    [self setNeedsLayout];
}

- (void)setType:(ExerciseNowCompletingViewType)type {
    _type = type;
    
    if(self.type == ExerciseNowCompletingViewTypeSingle) {
        self.titleLabel.hidden = NO;
        self.completionSubtitleLabel.hidden = NO;
        
    } else {
        
        self.titleLabel.hidden = YES;
        self.completionSubtitleLabel.hidden = YES;
    }
}

#pragma mark - ExerciseMediaViewDelegate Methods
- (void)exerciseMediaView:(ExerciseMediaView*)scrollView didTapImageViewWithParameters:(NSDictionary*)parameters {
//    NSLog(@"exerciseMediaView:didTapImageViewWithParameters:");
    
    if([self.delegate respondsToSelector:@selector(exerciseNowCompletingView:didTapImageViewWithParameters:)]) {
        [self.delegate performSelector:@selector(exerciseNowCompletingView:didTapImageViewWithParameters:) withObject:self withObject:parameters];
    }
}

// Methods for controlling next and previous step functionality, disabling buttons on array bounds, moving tableview on tap, etc
- (void)exerciseMediaView:(ExerciseMediaView*)scrollView didTapDirectionButtonWithDirection:(NSNumber*)direction {
    
    ExerciseMediaViewDirection selectedDirection = [direction integerValue];
    NSIndexPath * currentIndexPath = [self.instructionsTableView indexPathForSelectedRow];
    
    NSArray * instructionsForSelectedExercise = nil;
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        instructionsForSelectedExercise = [(Exercise*)self.selectedExercise getInstructionList];
    } else {
        instructionsForSelectedExercise = ((PractitionerExercise*)self.selectedExercise).instructions;
    }
    
    // Bounds check each movement operation before performing it
    NSIndexPath * destinationIndexPath = nil;
    if(selectedDirection == ExerciseMediaViewDirectionPrevious && currentIndexPath.row > 0) {
        destinationIndexPath = [NSIndexPath indexPathForRow:(currentIndexPath.row - 1) inSection:0];
        [self.instructionsTableView updateSelectedIndexPath:destinationIndexPath shouldScrollToNewIndexPath:YES shouldNotifyDelegate:NO];
        
    } else if(selectedDirection == ExerciseMediaViewDirectionNext && currentIndexPath.row < ([instructionsForSelectedExercise count] - 1)) {
        destinationIndexPath = [NSIndexPath indexPathForRow:(currentIndexPath.row + 1) inSection:0];
        [self.instructionsTableView updateSelectedIndexPath:destinationIndexPath shouldScrollToNewIndexPath:YES shouldNotifyDelegate:NO];
    }
    
    // Update enabled/disabled status of next and previous buttons depending on current position in the instructions
    if(destinationIndexPath) {
        [self updateNavigationButtonsWithIndexPath:destinationIndexPath];
    }
}

- (void)exerciseInstructionTableView:(ExerciseInstructionTableView*)tableView selectedRowDidChangeToNewIndexPath:(NSIndexPath*)row {
    [self updateNavigationButtonsWithIndexPath:row];
}

#pragma mark - Private Methods
- (void)updateNavigationButtonsWithIndexPath:(NSIndexPath *)destinationIndexPath {
    
    NSArray * instructionsForSelectedExercise = nil;
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        instructionsForSelectedExercise = [(Exercise*)self.selectedExercise getInstructionList];
    } else {
        instructionsForSelectedExercise = ((PractitionerExercise*)self.selectedExercise).instructions;
    }
    
    if(destinationIndexPath.row == ([instructionsForSelectedExercise count] - 1)) {
        [self.mediaView setNextStepButtonEnabled:NO];
    } else {
        [self.mediaView setNextStepButtonEnabled:YES];
    }
    
    if(destinationIndexPath.row == 0) {
        [self.mediaView setPreviousStepButtonEnabled:NO];
    } else {
        [self.mediaView setPreviousStepButtonEnabled:YES];
    }
}

@end
