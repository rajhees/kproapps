//
//  ExerciseMediaSelectButton.m
//  StretchMate
//
//  Created by James Eunson on 24/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseSelectButtonView.h"

@interface ExerciseSelectButtonView()
@end

@implementation ExerciseSelectButtonView

- (id)initWithFrame:(CGRect)frame andType:(ExerciseMediaButtonType)type andInitiallySelected:(BOOL)initiallySelected
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.type = type;
        
        if(type == ExerciseMediaButtonTypeImages) {
            self.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-images-icon"]];
        } else if(type == ExerciseMediaButtonTypeVideo) {
            self.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-video-icon"]];
        } else {
            self.iconView = [[UIImageView alloc] init];
        }
        _iconView.frame = CGRectMake(9, 6, _iconView.frame.size.width, _iconView.frame.size.height);
        
        [self addSubview:_iconView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.frame.size.width-30, self.frame.size.height)];
        if(type == ExerciseMediaButtonTypeImages) {
            _titleLabel.text = @"Images";
        } else if(type == ExerciseMediaButtonTypeVideo) {
            _titleLabel.text = @"Video";
        }
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_titleLabel];
        
        if(!initiallySelected) {
            _iconView.alpha = 0.5f;
        }
    }
    return self;
}

@end
