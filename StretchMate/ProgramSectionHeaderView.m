//
//  ProgramSectionHeader.m
//  Exersite
//
//  Created by James Eunson on 19/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramSectionHeaderView.h"

@implementation ProgramSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.sectionBackgroundView = [[UIView alloc] init];
        _sectionBackgroundView.backgroundColor = RGBCOLOR(247, 247, 247);
        [self addSubview:_sectionBackgroundView];
        
        self.titleLabel = [[UILabel alloc] init];
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _titleLabel.textColor = RGBCOLOR(51, 51, 51);
        
        [self addSubview:self.titleLabel];
        
        self.bottomBorderLayer = [CALayer layer];
        [_bottomBorderLayer setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_bottomBorderLayer];
        
        self.actionLabel = [[UILabel alloc] init];
        
        _actionLabel.textColor = kTintColour;
        _actionLabel.font = [UIFont systemFontOfSize:14.0f];
        _actionLabel.textAlignment = NSTextAlignmentRight;
        _actionLabel.backgroundColor = [UIColor clearColor];
        _actionLabel.hidden = YES;
        [self addSubview:_actionLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX)];
    self.titleLabel.frame = CGRectMake(10, 4, sizeForTitleLabel.width, self.frame.size.height - 8);
    
    self.sectionBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self.bottomBorderLayer setFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    
    CGSize sizeForActionLabel = [self.actionLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    self.actionLabel.frame = CGRectMake(self.frame.size.width - sizeForActionLabel.width - 8.0f, 0, sizeForActionLabel.width, self.frame.size.height);
}

@end
