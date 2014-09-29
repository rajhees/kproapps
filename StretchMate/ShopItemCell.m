//
//  ShopItemCell.m
//  StretchMate
//
//  Created by James Eunson on 4/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopItemCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"

@implementation ShopItemCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        self.overlayInsetTimerImageView.hidden = YES;
        self.overlayInsetViewLabel.textColor = kTintColour;
        
        self.itemImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)setItemDict:(NSDictionary *)itemDict {
    _itemDict = itemDict;
    
    self.itemTitleString = _itemDict[@"name"];
    self.itemExercisesContainerLabel.text = _itemDict[@"category"];
    
    if(self.type == ShopItemCellTypeItem) {
     
        self.overlayInsetView.hidden = NO;
        self.exercisesContainerView.hidden = NO;
        self.exercisesContainerArrowImageView.hidden = NO;
        self.titleSeparatorBorderLayer.hidden = NO;
        
        float itemPrice = [_itemDict[@"price"] floatValue]; // Interpreted as NSNumber by parser
        NSString * itemPriceString = [NSString stringWithFormat:@"A$%.2f", itemPrice];
        
        self.overlayInsetViewLabel.text = itemPriceString;
        self.overlayInsetViewLabel.adjustsLetterSpacingToFitWidth = YES;
        self.overlayInsetViewLabel.numberOfLines = 1;
        
    } else {
        
        self.itemTitleString = _itemDict[@"name"];
        
        self.overlayInsetView.hidden = YES;
        self.exercisesContainerView.hidden = YES;
        self.exercisesContainerArrowImageView.hidden = YES;
        self.titleSeparatorBorderLayer.hidden = YES;
    }
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:_itemDict[@"image"]]];
    
    __block ShopItemCell * blockCell = self;
    __block UIImageView * blockItemImageView = self.itemImageView;
    
    [blockItemImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        blockCell.itemImageView.image = image;
        [blockCell setNeedsLayout];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {}];
    
    [self setNeedsLayout];
}

+ (CGFloat)verticalOffsetForOverviewImageWithTitleString:(NSString*)itemTitleString {
    
    CGSize sizeForItemTitle = sizeForItemTitle = [itemTitleString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 16, 40) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat topCapViewHeight = sizeForItemTitle.height + 7;
    
    return topCapViewHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.overlayInsetView.frame = CGRectMake(self.frame.size.width - (roundf(self.frame.size.width / 2)), 10, (roundf(self.frame.size.width / 2)), 30.0f);
    
    UIBezierPath * overlayInsetViewPath = [UIBezierPath bezierPathWithRoundedRect:self.overlayInsetView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(4.0, 4.0)];
    
    CAShapeLayer * overlayInsetMaskLayer = [CAShapeLayer layer];
    overlayInsetMaskLayer.frame = self.overlayInsetView.bounds;
    overlayInsetMaskLayer.path = overlayInsetViewPath.CGPath;
    self.overlayInsetView.layer.mask = overlayInsetMaskLayer;
    
    self.overlayInsetView.layer.masksToBounds = YES;
    
    if(!self.overlayInsetTimerImageView.hidden) {
        self.overlayInsetTimerImageView.frame = CGRectMake(4.0f, (self.overlayInsetView.frame.size.height / 2) - (14.0f / 2) + 1.0f, 14.0f, 14.0f);
        self.overlayInsetViewLabel.frame = CGRectMake(22.0f, 0, self.overlayInsetView.frame.size.width - 22.0f, self.overlayInsetView.frame.size.height);
    } else {
        self.overlayInsetViewLabel.frame = CGRectMake(8.0f, 0, self.overlayInsetView.frame.size.width - 4.0f, self.overlayInsetView.frame.size.height);
    }
    
    self.overlayInsetRightMaskView.frame = CGRectMake(self.frame.size.width - 1.0f, 11.0f, 1.0f, 28.0f);
}

+ (CGFloat)heightForShopItem:(NSDictionary*)shopItem {
    
    CGFloat height = kProgramCellWidth - 44.0f + 2.0f; // 2.0f border, 1 each end
    
    CGSize sizeForItemTitle = [shopItem[@"name"] sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 10, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    height += sizeForItemTitle.height + 4 + 4 + 1 + 6;
    
    CGSize sizeForExercisesContainerLabel = [shopItem[@"category"] sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 16, CGFLOAT_MAX)];
    height += sizeForExercisesContainerLabel.height + 12;
    
    return roundf(height);
}

@end
