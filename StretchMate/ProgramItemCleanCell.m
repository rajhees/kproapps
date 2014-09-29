//
//  ProgramItemCleanCell.m
//  Exersite
//
//  Created by James Eunson on 19/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramItemCleanCell.h"

@interface ProgramItemCleanCell ()

@end

@implementation ProgramItemCleanCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.masksToBounds = YES;
        
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        _containerView.layer.cornerRadius = 4.0f;
        _containerView.layer.borderColor = [RGBCOLOR(221, 221, 221) CGColor];
        _containerView.layer.borderWidth = 1.0f;
        
        _containerView.backgroundColor = [UIColor whiteColor];
        
        self.itemLabel = [[UILabel alloc] init];
        
        _itemLabel.backgroundColor = [UIColor clearColor];
        _itemLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _itemLabel.textColor = RGBCOLOR(57, 58, 70);
        _itemLabel.numberOfLines = 0;
        _itemLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_containerView addSubview:self.itemLabel];
        
        self.itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 98.0f)];
        
        _itemImageView.layer.cornerRadius = 4.0f;
        _itemImageView.layer.masksToBounds = YES;
        _itemImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIBezierPath * itemImageViewPath = [UIBezierPath bezierPathWithRoundedRect:_itemImageView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(4.0, 4.0)];
        
        CAShapeLayer * itemImageViewMaskLayer = [CAShapeLayer layer];
        itemImageViewMaskLayer.frame = _itemImageView.bounds;
        itemImageViewMaskLayer.path = itemImageViewPath.CGPath;
        _itemImageView.layer.mask = itemImageViewMaskLayer;
        
        [_containerView addSubview:self.itemImageView];
        
        CALayer * itemImageBottomBorderLayer = [CALayer layer];
        [itemImageBottomBorderLayer setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [itemImageBottomBorderLayer setFrame:CGRectMake(0, frame.size.width - 45.0f, frame.size.width, 1)];
        [_containerView.layer addSublayer:itemImageBottomBorderLayer];
        
        self.titleSeparatorBorderLayer = [CALayer layer];
        [_titleSeparatorBorderLayer setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [_containerView.layer addSublayer:_titleSeparatorBorderLayer];
        
        self.exercisesContainerView = [[UIView alloc] init];
        _exercisesContainerView.layer.cornerRadius = 4.0f;
        _exercisesContainerView.layer.borderColor = [RGBCOLOR(221, 221, 221) CGColor];
        _exercisesContainerView.layer.borderWidth = 1.0f;
        
        self.itemExercisesContainerLabel = [[UILabel alloc] init];
        _itemExercisesContainerLabel.backgroundColor = [UIColor clearColor];
        _itemExercisesContainerLabel.font = [UIFont systemFontOfSize:12.0f];
        _itemExercisesContainerLabel.textColor = RGBCOLOR(142, 142, 149);
        _itemExercisesContainerLabel.numberOfLines = 1;
        
        [_exercisesContainerView addSubview:_itemExercisesContainerLabel];
        
        self.exercisesContainerArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"program-item-arrow-ios7"]];
        [_exercisesContainerView addSubview:_exercisesContainerArrowImageView];
        
        [_containerView addSubview:_exercisesContainerView];
        
        self.overlayInsetView = [[UIView alloc] init];
        
        _overlayInsetView.backgroundColor = RGBCOLOR(238, 238, 238);
        _overlayInsetView.layer.borderColor = [RGBCOLOR(221, 221, 221) CGColor];
        _overlayInsetView.layer.borderWidth = 1.0f;
        
        self.overlayInsetTimerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"program-item-timer-ios7"]];
        [_overlayInsetView addSubview:_overlayInsetTimerImageView];
        
        self.overlayInsetViewLabel = [[UILabel alloc] init];
        
        _overlayInsetViewLabel.backgroundColor = [UIColor clearColor];
        _overlayInsetViewLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _overlayInsetViewLabel.textColor = RGBCOLOR(142, 142, 149);
        _overlayInsetViewLabel.numberOfLines = 0;
        _overlayInsetViewLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _overlayInsetViewLabel.text = @"16m";
        
        [_overlayInsetView addSubview: _overlayInsetViewLabel];
        
        [_containerView addSubview:_overlayInsetView];
        [self addSubview:_containerView];
        
        self.overlayInsetRightMaskView = [[UIView alloc] init];
        _overlayInsetRightMaskView.backgroundColor = RGBCOLOR(238, 238, 238);
        [self addSubview:_overlayInsetRightMaskView];
        [self bringSubviewToFront:_overlayInsetRightMaskView];
        
        [self setNeedsLayout];	
    }
    return self;
}

- (void)setItemTitleString:(NSString *)itemTitleString {
    
    _itemTitleString = itemTitleString;
    self.itemLabel.text = _itemTitleString;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.containerView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CGSize sizeForItemTitle = [self.itemLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 10, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.itemLabel.frame = CGRectMake(5, self.frame.size.width - 44 + 4, self.frame.size.width - 10.0f, sizeForItemTitle.height);
    
    [_titleSeparatorBorderLayer setFrame:CGRectMake(6, _itemLabel.frame.origin.y + _itemLabel.frame.size.height + 4, self.frame.size.width - 12, 1)];
    
    _exercisesContainerView.frame = CGRectMake(6, _titleSeparatorBorderLayer.frame.origin.y + 6, self.frame.size.width - 12, 24.0f);
    
    CGSize sizeForExercisesContainerLabel = [_itemExercisesContainerLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16, CGFLOAT_MAX)];
    _itemExercisesContainerLabel.frame = CGRectMake(6, 4, self.frame.size.width - 12, sizeForExercisesContainerLabel.height);
    
    _exercisesContainerArrowImageView.frame = CGRectMake(_exercisesContainerView.frame.size.width - _exercisesContainerArrowImageView.frame.size.width - 6.0f, (_exercisesContainerView.frame.size.height / 2) - (_exercisesContainerArrowImageView.frame.size.height / 2), _exercisesContainerArrowImageView.frame.size.width, _exercisesContainerArrowImageView.frame.size.height);
    
    _overlayInsetView.frame = CGRectMake(self.frame.size.width - (roundf(self.frame.size.width / 5) * 2), 10, (roundf(self.frame.size.width / 5) * 2), 30.0f);
    
    UIBezierPath * overlayInsetViewPath = [UIBezierPath bezierPathWithRoundedRect:_overlayInsetView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(4.0, 4.0)];
    
    CAShapeLayer * overlayInsetMaskLayer = [CAShapeLayer layer];
    overlayInsetMaskLayer.frame = _overlayInsetView.bounds;
    overlayInsetMaskLayer.path = overlayInsetViewPath.CGPath;
    _overlayInsetView.layer.mask = overlayInsetMaskLayer;
    
    _overlayInsetView.layer.masksToBounds = YES;
    _overlayInsetTimerImageView.frame = CGRectMake(4.0f, (_overlayInsetView.frame.size.height / 2) - (14.0f / 2) + 1.0f, 14.0f, 14.0f);
    _overlayInsetViewLabel.frame = CGRectMake(22.0f, 0, _overlayInsetView.frame.size.width - 22.0f, _overlayInsetView.frame.size.height);
    
    _overlayInsetRightMaskView.frame = CGRectMake(self.frame.size.width - 1.0f, 11.0f, 1.0f, 28.0f);
}

+ (CGFloat)heightForCellWithProgram:(Program*)program {
    
    CGFloat height = kProgramCellWidth - 44.0f + 2.0f; // 2.0f border, 1 each end
    
    CGSize sizeForItemTitle = [program.title sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 10, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    height += sizeForItemTitle.height + 4 + 4 + 1 + 6;
    
    CGSize sizeForExercisesContainerLabel = [[program getExerciseString] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 16, CGFLOAT_MAX)];
    height += sizeForExercisesContainerLabel.height + 4;
    
    return roundf(height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
