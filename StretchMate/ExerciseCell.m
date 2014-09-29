//
//  ExerciseCell.m
//  StretchMate
//
//  Created by James Eunson on 28/11/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseCell.h"
#import "ExerciseStarView.h"
#import "Exercise.h"

@implementation ExerciseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            self.detailTextLabel.textColor = [UIColor grayColor];
            self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            self.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        
        self.imageView.frame = CGRectMake(0, 0, 55, 55);
        
        self.textLabel.frame = CGRectMake(70, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        self.detailTextLabel.frame = CGRectMake(70, self.detailTextLabel.frame.origin.y, self.detailTextLabel.frame.size.width + 30.0f, self.detailTextLabel.frame.size.height);
    }
}

#pragma mark - Property Override
- (void)setStarView:(ExerciseStarView *)starView {
    
    _starView = starView;
    [self addSubview:starView];
}

- (void)setSelectedExercise:(id)selectedExercise {
    _selectedExercise = selectedExercise;
    
    Exercise * databaseExercise = (Exercise*)selectedExercise;
    
    self.textLabel.text = databaseExercise.nameBasic;
    self.detailTextLabel.text = databaseExercise.typesString;
    
    self.imageView.image = [databaseExercise getThumbnailImage];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self setNeedsLayout];
}

@end
