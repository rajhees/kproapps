//
//  ExerciseDetailSubtitleCell.m
//  Exersite
//
//  Created by James Eunson on 26/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseDetailSubtitleCell.h"

#define kSideContainerViewHeight 34.0f

@implementation ExerciseDetailSubtitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.textLabel.textColor = RGBCOLOR(57, 58, 70);
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        self.detailTextLabel.textColor = RGBCOLOR(142, 142, 149);
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.sideContainerView = [[UIView alloc] init];
        _sideContainerView.layer.cornerRadius = 4.0f;
        [self.contentView addSubview:_sideContainerView];
        
        self.purposeInfoIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-purpose-info-icon-ios7"]];
        _purposeInfoIconImageView.hidden = YES;
        _purposeInfoIconImageView.contentMode = UIViewContentModeCenter;
        [_sideContainerView addSubview:_purposeInfoIconImageView];
        
        self.equipmentIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-equipment-icon-ios7"]];
        _equipmentIconImageView.hidden = YES;
        _equipmentIconImageView.contentMode = UIViewContentModeCenter;
        [_sideContainerView addSubview:_equipmentIconImageView];
        
        self.difficultyLetterLabel = [[UILabel alloc] init];
        _difficultyLetterLabel.font = [UIFont boldSystemFontOfSize:22.0f];
        _difficultyLetterLabel.backgroundColor = [UIColor clearColor];
        _difficultyLetterLabel.textColor = [UIColor whiteColor];
        _difficultyLetterLabel.textAlignment = NSTextAlignmentCenter;
        [_sideContainerView addSubview:_difficultyLetterLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(8.0f, (self.frame.size.height / 2) - (kSideContainerViewHeight / 2), kSideContainerViewHeight, kSideContainerViewHeight);
    self.textLabel.frame = CGRectMake(54.0f, 7.0f, self.frame.size.width - 54.0f - 8.0f, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(54.0f, self.textLabel.frame.origin.y + self.textLabel.frame.size.height, self.frame.size.width - 54.0f - 8.0f, self.detailTextLabel.frame.size.height);
    
    self.sideContainerView.frame = CGRectMake(8.0f, 8.0f, kSideContainerViewHeight, kSideContainerViewHeight);
    
    self.purposeInfoIconImageView.frame = CGRectMake(0, 0, _sideContainerView.frame.size.width, _sideContainerView.frame.size.height);
    self.equipmentIconImageView.frame = CGRectMake(0, 0, _sideContainerView.frame.size.width, _sideContainerView.frame.size.height);
    self.difficultyLetterLabel.frame = CGRectMake(0, 0, _sideContainerView.frame.size.width, _sideContainerView.frame.size.height);
}

+ (CGFloat)heightForCellWithText:(NSString*)text detailText:(NSString*)detailText {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGSize sizeForText = [text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 54.0f - 8.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize sizeForDetailText = [detailText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 54.0f - 8.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    return 12.0f + sizeForText.height + sizeForDetailText.height + 8.0f;
}

#pragma mark - Property Override
- (void)setType:(ExerciseDetailSubtitleCellType)type {
    _type = type;
    
    if(self.type == ExerciseDetailSubtitleCellTypeDifficulty) {
        
        self.difficultyLetterLabel.hidden = NO;
        
    } else if(self.type == ExerciseDetailSubtitleCellTypePurpose) {
        
        self.purposeInfoIconImageView.hidden = NO;
        _sideContainerView.backgroundColor = RGBCOLOR(142, 142, 149);
        
    } else if(self.type == ExerciseDetailSubtitleCellTypeEquipment) {
        
        self.equipmentIconImageView.hidden = NO;
        self.sideContainerView.backgroundColor = RGBCOLOR(142, 142, 149);
    }
}

- (void)setDifficultyLevel:(ExerciseDetailSubtitleCellDifficultyType)difficultyLevel {
    _difficultyLevel = difficultyLevel;
    
    if(self.type != ExerciseDetailSubtitleCellTypeDifficulty) {
        self.type = ExerciseDetailSubtitleCellTypeDifficulty;
    }
    
    self.difficultyLetterLabel.text = kDifficultyLetterLookup[@(difficultyLevel)];
    self.sideContainerView.backgroundColor = kDifficultyColorLookup[@(difficultyLevel)];
}

@end
