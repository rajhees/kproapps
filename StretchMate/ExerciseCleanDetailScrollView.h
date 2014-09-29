//
//  ExerciseCleanDetailScrollView.h
//  Exersite
//
//  Created by James Eunson on 25/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"
#import "ExerciseInstructionTableView.h"
#import "ExerciseBigButton.h"
#import "ExerciseMediaView.h"
#import "Program.h"

#define kSelectedImagePath @"selectedImagePath"

@protocol ExerciseCleanDetailScrollViewDelegate;
@interface ExerciseCleanDetailScrollView : UIScrollView <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, ExerciseMediaViewDelegate>

@property (nonatomic, strong) id selectedExercise;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * technicalTitleLabel;

@property (nonatomic, strong) UIButton * subtitleButton;
@property (nonatomic, strong) UILabel * subtitleLabel;
@property (nonatomic, strong) UIImageView * subtitleArrowImageView;

@property (nonatomic, strong) UIView * starredContainerView;
@property (nonatomic, strong) UIButton * starredButton;

@property (nonatomic, strong) ExerciseMediaView * mediaView;

@property (nonatomic, strong) UILabel * instructionsTitleLabel;
@property (nonatomic, strong) CALayer * instructionsTableViewTopBorder;
@property (nonatomic, strong) ExerciseInstructionTableView * instructionsTableView;

@property (nonatomic, strong) UILabel * moreInformationTitleLabel;
@property (nonatomic, strong) CALayer * moreInformationTopBorder;
@property (nonatomic, strong) UITableView * moreInformationTableView;

@property (nonatomic, strong) UILabel * equipmentTitleLabel;
@property (nonatomic, strong) CALayer * equipmentTopBorder;
@property (nonatomic, strong) UITableView * equipmentTableView;

@property (nonatomic, strong) UILabel * prescribedTimesTitleLabel;
@property (nonatomic, strong) CALayer * prescribedTimesTopBorder;
@property (nonatomic, strong) UITableView * prescribedTimesTableView;
@property (nonatomic, strong) UIButton * prescribedTimesViewAllButton;

@property (nonatomic, strong) UILabel * relatedProgramsTitleLabel;
@property (nonatomic, strong) CALayer * relatedProgramsTopBorder;
@property (nonatomic, strong) UITableView * relatedProgramsTableView;

@property (nonatomic, strong) UILabel * relatedExercisesTitleLabel;
@property (nonatomic, strong) CALayer * relatedExercisesTopBorder;
@property (nonatomic, strong) UITableView * relatedExercisesTableView;

@property (nonatomic, strong) ExerciseBigButton * addToMyExercisesButton;
@property (nonatomic, strong) ExerciseBigButton * startExerciseButton;

@property (nonatomic, assign) __unsafe_unretained id<ExerciseCleanDetailScrollViewDelegate> exerciseDetailDelegate;

@property (nonatomic, strong) NSArray * equipmentCategories;

+ (CGFloat)heightForScrollViewWithExercise:(id)selectedExercise;
- (void)updateMediaScrollViewContentOffset;

@end

@protocol ExerciseCleanDetailScrollViewDelegate <NSObject>
@required
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didTapSubtitleButton:(UIButton*)button;
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didTapStarredButton:(UIButton*)button;
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didTapImageViewWithParameters:(NSDictionary*)parameters;
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didSelectRelatedExercise:(Exercise*)exercise;
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didSelectDifficultyExplanationWithIndexPath:(NSIndexPath*)indexPath;
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didTapStartExerciseButton:(UIButton*)button;
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didSelectRelatedProgram:(Program*)program;
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didSelectEquipmentCategory:(NSDictionary*)category;
@end