//
//  ShopCategoryToolbarButton.m
//  Exersite
//
//  Created by James Eunson on 21/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCategoryToolbarButton.h"

@interface ShopCategoryToolbarButton ()

@property (nonatomic, strong) UIView * highlightedBackgroundView;

@end

@implementation ShopCategoryToolbarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        
        [self setTitleColor:RGBCOLOR(57, 58, 70) forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.layer.cornerRadius = 4.0f;
    }
    return self;
}

- (void)setCategoryNameString:(NSString *)categoryNameString {
    _categoryNameString = categoryNameString;
    
    [self setTitle:categoryNameString forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        self.backgroundColor = RGBCOLOR(71, 72, 83);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (CGSize)intrinsicContentSize {
    
    if(self.categoryNameString) {
        
        CGSize sizeForTitle = [self.categoryNameString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]];
        return CGSizeMake(sizeForTitle.width + 10.0f, sizeForTitle.height + 12.0f);
        
    } else {
        return CGSizeZero;
    }
}

@end
