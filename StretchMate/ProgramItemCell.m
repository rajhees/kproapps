//
//  ProgramItemCell.m
//  StretchMate
//
//  Created by James Eunson on 16/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramItemCell.h"
#import "ShopItemCell.h"

#define kHighlightedCellGradient @[ (id)[RGBCOLOR(5, 140, 245) CGColor], (id)[RGBCOLOR(1, 93, 230) CGColor] ]

@implementation ProgramItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.backgroundColor = [UIColor redColor];
        
        // Shadow underneath
        UIImageView * shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-item-shadow"]];
        shadowImageView.frame = CGRectMake(0, 95, shadowImageView.frame.size.width, shadowImageView.frame.size.height);
        shadowImageView.alpha = 0.7f;
        [self addSubview:shadowImageView];
        
        // Base container
        UIView * containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kProgramCellWidth, kProgramCellHeight)];
        
        containerView.layer.cornerRadius = 5.0f;
        containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
        containerView.layer.shadowOffset = CGSizeMake(0, 1.0f);
        containerView.layer.shadowOpacity = 0.75f;
        containerView.layer.shadowRadius = 1.0f;
        containerView.backgroundColor = [UIColor clearColor];
        
        UIImage * resizableProgramItemBackgroundImage = [[UIImage imageNamed:@"programs-item-container"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 12, 9)];
        UIImageView * programItemBackgroundImageView = [[UIImageView alloc] initWithImage:resizableProgramItemBackgroundImage];
        programItemBackgroundImageView.frame = CGRectMake(0, 0, kProgramCellWidth, kProgramCellHeight);
        [containerView addSubview:programItemBackgroundImageView];
        
        // Top cap
        UIImage * resizableTopCapImage = [[UIImage imageNamed:@"program-item-top-cap"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 2, 10)];
        self.topCapImageView = [[UIImageView alloc] initWithImage:resizableTopCapImage];
        _topCapImageView.frame = CGRectMake(0, -3, kProgramCellWidth, 50);
        [containerView addSubview:_topCapImageView];
        
        UIView * gutterView = [[UIView alloc] initWithFrame:CGRectMake(kProgramInsetSize/2 - 1, kProgramCellHeight - kProgramGutterHeight - kProgramGutterBottomMargin, kProgramCellWidth - kProgramInsetSize + 2, kProgramGutterHeight)];
        UIImage * gutterResizableBackgroundImage = [[UIImage imageNamed:@"program-item-gutter"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 6, 0, 6)];
        UIImageView * gutterBackgroundImageView = [[UIImageView alloc] initWithImage:gutterResizableBackgroundImage];
        
        gutterBackgroundImageView.frame = CGRectMake(0, 0, gutterView.frame.size.width, kProgramGutterHeight);
        [gutterView addSubview:gutterBackgroundImageView];
        
        UIImageView * gutterDisclosureIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"program-gutter-detail-disclosure-indicator"]];
        gutterDisclosureIndicatorView.frame = CGRectMake(gutterView.frame.size.width - 10, 8, gutterDisclosureIndicatorView.frame.size.width, gutterDisclosureIndicatorView.frame.size.height);
        [gutterView addSubview:gutterDisclosureIndicatorView];
        
        self.itemGutterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, gutterView.frame.size.width, gutterView.frame.size.height)];
        _itemGutterLabel.backgroundColor = [UIColor clearColor];
        _itemGutterLabel.font = [UIFont systemFontOfSize:12.0f];
        _itemGutterLabel.textColor = RGBCOLOR(136, 136, 136);
        _itemGutterLabel.shadowColor = RGBCOLOR(238, 238, 238);
        _itemGutterLabel.shadowOffset = CGSizeMake(0, 1.0f);
        _itemGutterLabel.numberOfLines = 1;
        [gutterView addSubview:self.itemGutterLabel];
        
        [containerView addSubview:gutterView];
        
        CAGradientLayer * itemHighlightLayer = [CAGradientLayer layer];
        [itemHighlightLayer setFrame:CGRectMake(0, 0, kProgramCellWidth, kProgramCellHeight)];
        itemHighlightLayer.actions = @{@"opacity": [NSNull null]};
        itemHighlightLayer.colors = kHighlightedCellGradient;
        itemHighlightLayer.cornerRadius = 6.0f;
        
        self.itemHighlightView = [[UIView alloc] initWithFrame:CGRectMake(0, -3, kProgramCellWidth, kProgramCellHeight)];
        [_itemHighlightView.layer insertSublayer:itemHighlightLayer atIndex:0];
        _itemHighlightView.alpha = 0.0f;
        [containerView addSubview:self.itemHighlightView];
        
        // Item image
        self.itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width-kProgramInsetSize, kProgramCellHeight-kProgramInsetSize-4)];
//        UIImage * thumbnailImage = [UIImage imageNamed:@"shop-filler-image"];
//        _itemImageView.image = thumbnailImage;
        _itemImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _itemImageView.layer.borderWidth = 3.0f;
        _itemImageView.layer.cornerRadius = 4.0f;
        _itemImageView.layer.masksToBounds = NO;
        
        [containerView addSubview:self.itemImageView];
        
        self.itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, kProgramCellWidth-5, 40)];
        _itemLabel.backgroundColor = [UIColor clearColor];
        _itemLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _itemLabel.textColor = [UIColor whiteColor];
        _itemLabel.shadowColor = RGBCOLOR(18, 21, 30);
        _itemLabel.shadowOffset = CGSizeMake(0, -1.0f);
        _itemLabel.numberOfLines = 0;
        _itemLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [containerView addSubview:self.itemLabel];
        
        containerView.userInteractionEnabled = NO;
        
        [self addSubview:containerView];
        
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.shouldRasterize = YES;
    }
    return self;
}

- (void)setItemTitleString:(NSString *)itemTitleString {
    
    _itemTitleString = itemTitleString;
    
    // Dirty hack, owing to weirdness in Obj-C inheritance (can't override property setter method in subclass)
    CGSize sizeForItemTitle = CGSizeZero;
    if([self isKindOfClass:[ShopItemCell class]]) {
        
        sizeForItemTitle = [itemTitleString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 16, 40) lineBreakMode:UILineBreakModeTailTruncation];
        self.itemLabel.numberOfLines = 2;
        self.itemLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
    } else {
        sizeForItemTitle = [itemTitleString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 16, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    self.topCapImageView.frame = CGRectMake(0, -3, kProgramCellWidth, sizeForItemTitle.height + 10);
    
    self.itemLabel.frame = CGRectMake(8, 2, kProgramCellWidth-16, sizeForItemTitle.height);
    self.itemLabel.text = itemTitleString;
}

+ (CGSize)sizeForOverviewImageWithTitleString:(NSString*)itemTitleString {

    CGFloat topCapViewHeight = [[self class] verticalOffsetForOverviewImageWithTitleString:itemTitleString];
    CGFloat overviewImageHeight = kProgramCellHeight - topCapViewHeight - kProgramGutterHeight - 5;
    
//    NSLog(@"sizeForOverviewImageWithTitleString: %f", overviewImageHeight);
    
    return CGSizeMake(kProgramCellWidth - 10, overviewImageHeight);
}

+ (CGFloat)verticalOffsetForOverviewImageWithTitleString:(NSString*)itemTitleString {
    
    CGSize sizeForItemTitle = sizeForItemTitle = [itemTitleString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(kProgramCellWidth - 16, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat topCapViewHeight = sizeForItemTitle.height + 7;
    
    return topCapViewHeight;
}

@end
