//
//  ProgramItemCleanCell.h
//  Exersite
//
//  Created by James Eunson on 19/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"

#define kProgramCellHeight 142
#define kProgramCellWidth 142

@interface ProgramItemCleanCell : UICollectionViewCell

@property (nonatomic, strong) UIView * containerView;

@property (nonatomic, strong) UILabel * itemLabel;

@property (nonatomic, strong) UILabel * itemExercisesContainerLabel;
@property (nonatomic, strong) UIView * exercisesContainerView;
@property (nonatomic, strong) UIImageView * exercisesContainerArrowImageView;
@property (nonatomic, strong) CALayer * titleSeparatorBorderLayer;


@property (nonatomic, strong) UIImageView * itemImageView;

@property (nonatomic, strong) NSString * itemTitleString;

@property (nonatomic, strong) UILabel * overlayInsetViewLabel;
@property (nonatomic, strong) UIImageView * overlayInsetTimerImageView;
@property (nonatomic, strong) UIView * overlayInsetView;
@property (nonatomic, strong) UIView * overlayInsetRightMaskView; // Masks the right border, can't selectively apply borders in UIKit :(

+ (CGFloat)heightForCellWithProgram:(Program*)program;

@end
