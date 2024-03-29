//
//  PrescriptionNowCompletingCompleteView.m
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionNowCompletingCompleteView.h"

#define kTitleText @"Exercise Completed"
#define kBodyText @"You have already completed this exercise. There are other incomplete exercises in this set - navigate using the left and right arrow below, or swipe left or right."

@implementation PrescriptionNowCompletingCompleteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
        
        self.completeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-now-completing-complete-icon-ios7"]];
        [self addSubview:_completeImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kTintColour;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = kTitleText;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        self.bodyMessageLabel = [[UILabel alloc] init];
        _bodyMessageLabel.text = kBodyText;
        _bodyMessageLabel.font = [UIFont systemFontOfSize:13.0f];
        _bodyMessageLabel.textColor = RGBCOLOR(99, 100, 109);
        _bodyMessageLabel.backgroundColor = [UIColor clearColor];
        _bodyMessageLabel.numberOfLines = 0;
        _bodyMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _bodyMessageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bodyMessageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    CGSize sizeForBodyMessageLabel = [self.bodyMessageLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 100.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat startingPoint = (self.frame.size.height / 2) - ((_completeImageView.frame.size.height + 20.0f + sizeForTitleLabel.height + sizeForBodyMessageLabel.height) / 2);
    _completeImageView.frame = CGRectMake((self.frame.size.width / 2) - (_completeImageView.frame.size.width / 2), startingPoint, _completeImageView.frame.size.width, _completeImageView.frame.size.height);
    
    self.titleLabel.frame = CGRectMake(8, _completeImageView.frame.origin.y + _completeImageView.frame.size.height + 20.0f, self.frame.size.width - 16.0f, sizeForTitleLabel.height);
    _bodyMessageLabel.frame = CGRectMake((self.frame.size.width / 2) - ((self.frame.size.width - 100.0f) / 2), _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 8.0f, self.frame.size.width - 100.0f, sizeForBodyMessageLabel.height);
}
@end
