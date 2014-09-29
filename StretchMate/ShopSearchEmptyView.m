//
//  ShopSearchEmptyView.m
//  Exersite
//
//  Created by James Eunson on 26/10/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopSearchEmptyView.h"

@implementation ShopSearchEmptyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-search-empty-view-icon"]];
        [self addSubview:_imageView];
        
        // Determine correct text based on type of error message
        NSString * emptyText = @"Search the Exersite Shop";
        NSString * emptySubtitle = @"Enter your search terms above to begin.";
        
        // Title label
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = emptyText;
        _titleLabel.textColor = RGBCOLOR(102, 102, 102);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        // Subtitle label
        self.subtitleLabel = [[UILabel alloc] init];
        
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.text = emptySubtitle;
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_subtitleLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize emptySize = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    CGSize emptySubtitleSize = [self.subtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX)];
    
    CGFloat startingHeight = 0;
    startingHeight = (((self.frame.size.height / 2) - (_imageView.frame.size.height / 2)) - 50.0f) + _imageView.frame.size.height;
    _imageView.frame = CGRectMake((self.bounds.size.width - _imageView.frame.size.width) / 2, ((self.frame.size.height / 2) - (_imageView.frame.size.height / 2)) - 50.0f, _imageView.frame.size.width, _imageView.frame.size.height);

    self.titleLabel.frame = CGRectMake(8, startingHeight + 8 + 25.0f, self.bounds.size.width-16, emptySize.height);
    self.subtitleLabel.frame = CGRectMake((self.bounds.size.width - 220.0f) / 2, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 4.0f, 220.0f, emptySubtitleSize.height);
}
@end
