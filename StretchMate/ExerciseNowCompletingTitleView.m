//
//  ExerciseNowCompletingTitleView.m
//  Exersite
//
//  Created by James Eunson on 2/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingTitleView.h"

@implementation ExerciseNowCompletingTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        
        self.pageLabel = [[UILabel alloc] init];
        _pageLabel.font = [UIFont systemFontOfSize:13.0f];
        _pageLabel.textColor = [UIColor grayColor];
        _pageLabel.backgroundColor = [UIColor clearColor];
        _pageLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_pageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTitleLabel = [_titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:CGSizeMake(self.frame.size.width, 30.0f)];
    _titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, sizeForTitleLabel.height);
    
    CGSize sizeForPageLabel = [_pageLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width, 30.0f)];
    _pageLabel.frame = CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, self.frame.size.width, sizeForPageLabel.height);
}

@end
