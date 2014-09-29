//
//  RecipeSectionHeaderView.m
//  FODMAP
//
//  Created by James Eunson on 5/11/12.
//  Copyright (c) 2012 JEON. All rights reserved.
//

#import "ShopSectionHeaderView.h"

@implementation ShopSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView * sectionHeaderBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-section-header-bg"]];
        [sectionHeaderBackgroundView setFrame:CGRectMake(0, 0, sectionHeaderBackgroundView.frame.size.width, sectionHeaderBackgroundView.frame.size.height)];
        [self addSubview:sectionHeaderBackgroundView];
        
        self.sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, sectionHeaderBackgroundView.frame.size.width-28, sectionHeaderBackgroundView.frame.size.height)];
        _sectionTitleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        _sectionTitleLabel.textColor = RGBCOLOR(210, 210, 210);
        _sectionTitleLabel.backgroundColor = [UIColor clearColor];
        
        _sectionTitleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        _sectionTitleLabel.layer.shadowOffset = CGSizeMake(0, -1.0f);
        _sectionTitleLabel.layer.shadowOpacity = 0.5f;
        _sectionTitleLabel.layer.shadowRadius = 0.0f;
        
        [self addSubview:_sectionTitleLabel];
        
        CALayer * highlightBorderLayer = [CALayer layer];
        [highlightBorderLayer setBackgroundColor:RGBCOLOR(74, 74, 74).CGColor];
        [highlightBorderLayer setFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        [self.layer addSublayer:highlightBorderLayer];
        
        CALayer * innerShadowBorderLayer = [CALayer layer];
        [innerShadowBorderLayer setBackgroundColor:RGBCOLOR(20, 20, 20).CGColor];
        [innerShadowBorderLayer setFrame:CGRectMake(0, sectionHeaderBackgroundView.frame.size.height - 1, self.frame.size.width, 1)];
        [self.layer addSublayer:innerShadowBorderLayer];
        
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.shouldRasterize = YES;        
    }
    return self;
}

@end
