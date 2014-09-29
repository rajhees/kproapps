//
//  ExerciseInstrutionCell.h
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseInstrutionCell : UITableViewCell

@property (nonatomic, strong) CAGradientLayer * backgroundGradientLayer;
@property (nonatomic, strong) UILabel * numberLabel;
@property (nonatomic, strong) NSString * exerciseInstructionString;
@property (nonatomic, assign, getter = isCurrentSelectedCell) BOOL currentSelectedCell;
@property (nonatomic, strong) UIImageView * numberBackgroundView;

@property (nonatomic, strong) UIView * flatNumberBackgroundView;
@property (nonatomic, strong) UIView * flatHighlightView;

+ (CGFloat)heightWithExerciseInstructionString:(NSString*)exerciseInstructionString;

@end
