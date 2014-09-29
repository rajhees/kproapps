//
//  ExerciseDetailScrollView.h
//  StretchMate
//
//  Created by James Eunson on 24/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ExerciseSelectorView.h"
#import "ExerciseStarView.h"

//typedef enum {
//    ExerciseMediaViewImages,
//    ExerciseMediaViewVideo
//} ExerciseMediaViewType;

@protocol ExerciseGalleryViewDelegate;
@protocol ExerciseDetailScrollViewDelegate;
@interface ExerciseDetailScrollView : UIScrollView <UITableViewDataSource, UITableViewDelegate, ExerciseSelectionChangeDelegate, ExerciseGalleryViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

//@property (nonatomic, strong) UILabel * titleLabel;
//@property (nonatomic, strong) UILabel * subtitleLabel;
//@property (nonatomic, assign) __unsafe_unretained id<ExerciseDetailScrollViewDelegate> exerciseDelegate;
//@property (nonatomic, strong) UITableView * instructionsTableView;
//@property (nonatomic, strong) ExerciseStarView * starView;
//
//@property (nonatomic, strong) id selectedExercise;
//
//@property (nonatomic, strong) NSArray * mediaViews;
//@property (nonatomic, assign) ExerciseMediaViewType visibleMediaView;
//
//@property (nonatomic, strong) UICollectionView * equipmentCollectionView;
//
//@property (nonatomic, strong) UIButton * addToExercisesButton;
//
//@property (nonatomic, assign) BOOL videoInitiallyPlayed;
//
//@property (nonatomic, strong) UITableView * relatedExercisesTableView;
//
//@property (nonatomic, strong) UIView * containerView;
//
//- (id)initWithFrame:(CGRect)frame andExercise:(id)exercise;
//+ (CGFloat)heightForScrollViewWithExercise:(id)exercise;

@end

@protocol ExerciseDetailScrollViewDelegate <NSObject>
@required
- (void)exerciseDetailScrollView:(ExerciseDetailScrollView*)detailScrollView didTapGalleryButtonWithImage:(UIImage*)image;
- (void)exerciseDetailScrollView:(ExerciseDetailScrollView*)detailScrollView didTapVideoButton:(UIButton*)videoButton;
- (void)exerciseDetailScrollView:(ExerciseDetailScrollView *)detailScrollView didTapExerciseEquipmentItem:(NSString*)identifier;
- (void)exerciseDetailScrollView:(ExerciseDetailScrollView *)detailScrollView didTapDifficultyButton:(UIButton*)difficultyButton;
- (void)exerciseDetailScrollView:(ExerciseDetailScrollView *)detailScrollView didStartExercise:(Exercise*)exercise;
- (void)exerciseDetailScrollView:(ExerciseDetailScrollView *)detailScrollView shouldToggleExerciseInMyExercises:(Exercise*)exercise;
- (void)exerciseDetailScrollView:(ExerciseDetailScrollView *)detailScrollView didSelectRelatedExercise:(Exercise*)exercise;
@end