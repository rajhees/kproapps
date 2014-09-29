//
//  ExerciseDetailTagView.m
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseDetailTagView.h"

@interface ExerciseDetailTagView ()

@property (nonatomic, strong) UILabel * tagLabel;

@end

@implementation ExerciseDetailTagView

- (id)initWithFrame:(CGRect)frame andExerciseType:(id)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage * backgroundImage = [[UIImage imageNamed:@"exercise-detail-tag-bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:6];
        UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        [self addSubview:backgroundImageView];
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, frame.size.width, frame.size.height)];
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
        _tagLabel.shadowOffset = CGSizeMake(0, -1.0f);
        _tagLabel.font = [UIFont systemFontOfSize:13.0f];
        _tagLabel.textColor = [UIColor whiteColor];
        [self addSubview:_tagLabel];
        
        self.type = type;        
    }
    return self;
}

+ (CGFloat)widthForExerciseType:(id)type {
    
    NSString * typeString = nil;
    if([type isKindOfClass:[ExerciseType class]]) {
        typeString = ((ExerciseType*)type).name;
    } else {
        typeString = type;
    }
    
    CGSize sizeForExerciseTypeName = [typeString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    return sizeForExerciseTypeName.width + 10.0f;
}

#pragma mark - Property Override Methods
- (void)setType:(id)type {
    _type = type;
    
    if([type isKindOfClass:[ExerciseType class]]) {
        _tagLabel.text = ((ExerciseType*)type).name;
    } else {
        _tagLabel.text = type;
    }
}

@end
