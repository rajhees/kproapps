//
//  PrescriptionProgramDayEmptyView.m
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionProgramDayEmptyView.h"

@implementation PrescriptionProgramDayEmptyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = RGBCOLOR(238, 238, 238);
        
        // Determine correct text based on type of error message
        NSString * emptyText = @"No exercises prescribed for today";
        NSString * emptySubtitle = @"Use the left and right arrow above to\nmove between days or view all\nprescribed exercises using the All\nbutton below.";
        
        // Title label
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = emptyText;
        _titleLabel.textColor = RGBCOLOR(102, 102, 102);
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        // Subtitle label
        self.subtitleLabel = [[UILabel alloc] init];
        
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.text = emptySubtitle;
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_subtitleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize emptySize = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    CGSize emptySubtitleSize = [self.subtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX)];
    
    CGFloat startingHeight = 0;
    startingHeight = ((self.frame.size.height / 2) - ((emptySize.height + emptySubtitleSize.height) / 2));
    
    self.titleLabel.frame = CGRectMake(8, startingHeight, self.frame.size.width-16, emptySize.height);
    self.subtitleLabel.frame = CGRectMake((self.frame.size.width - 220.0f) / 2, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 4.0f, 220.0f, emptySubtitleSize.height);
}

@end
