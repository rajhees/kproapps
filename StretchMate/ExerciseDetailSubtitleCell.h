//
//  ExerciseDetailSubtitleCell.h
//  Exersite
//
//  Created by James Eunson on 26/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ExerciseDetailSubtitleCellTypePlain,
    ExerciseDetailSubtitleCellTypeDifficulty,
    ExerciseDetailSubtitleCellTypePurpose,
    ExerciseDetailSubtitleCellTypeEquipment
} ExerciseDetailSubtitleCellType;

// Only relevant if the type is ExerciseDetailSubtitleCellTypeDifficulty
typedef enum {
    ExerciseDetailSubtitleCellDifficultyTypeBasic,
    ExerciseDetailSubtitleCellDifficultyTypeIntermediate,
    ExerciseDetailSubtitleCellDifficultyTypeAdvanced
} ExerciseDetailSubtitleCellDifficultyType;


#define kDifficultyBasicColor RGBCOLOR(76, 217, 100)
#define kDifficultyIntermediateColor RGBCOLOR(255, 204, 0)
#define kDifficultyAdvancedColor RGBCOLOR(255, 59, 48)

#define kDifficultyBasicLetter @"B"
#define kDifficultyIntermediateLetter @"I"
#define kDifficultyAdvancedLetter @"A"

#define kDifficultyColorLookup @{ @(ExerciseDetailSubtitleCellDifficultyTypeBasic): kDifficultyBasicColor, @(ExerciseDetailSubtitleCellDifficultyTypeIntermediate): kDifficultyIntermediateColor, @(ExerciseDetailSubtitleCellDifficultyTypeAdvanced): kDifficultyAdvancedColor }

#define kDifficultyLetterLookup @{ @(ExerciseDetailSubtitleCellDifficultyTypeBasic): kDifficultyBasicLetter, @(ExerciseDetailSubtitleCellDifficultyTypeIntermediate): kDifficultyIntermediateLetter, @(ExerciseDetailSubtitleCellDifficultyTypeAdvanced): kDifficultyAdvancedLetter }

@interface ExerciseDetailSubtitleCell : UITableViewCell

+ (CGFloat)heightForCellWithText:(NSString*)text detailText:(NSString*)detailText;

@property (nonatomic, assign) ExerciseDetailSubtitleCellType type;

// Only relevant if the type is ExerciseDetailSubtitleCellTypeDifficulty, ExerciseDetailSubtitleCellTypePurpose or ExerciseDetailSubtitleCellTypeEquipment
@property (nonatomic, strong) UIView * sideContainerView;

@property (nonatomic, strong) UIImageView * purposeInfoIconImageView;
@property (nonatomic, strong) UIImageView * equipmentIconImageView;

@property (nonatomic, strong) UILabel * difficultyLetterLabel;
@property (nonatomic, assign) ExerciseDetailSubtitleCellDifficultyType difficultyLevel;

@end
