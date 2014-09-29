//
//  ShopCartItemCell.m
//  Exersite
//
//  Created by James Eunson on 5/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCartItemCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ShopCartItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.cartItemImageContainerView = [[UIView alloc] init];
        
        _cartItemImageContainerView.layer.borderColor = [RGBCOLOR(232, 232, 232) CGColor];
        _cartItemImageContainerView.layer.borderWidth = 1.0f;
        _cartItemImageContainerView.layer.cornerRadius = 4.0f;
        
        [self.contentView addSubview:_cartItemImageContainerView];
        
        self.cartItemImageView = [[UIImageView alloc] init];
        [_cartItemImageContainerView addSubview:_cartItemImageView];
        
        self.itemTitleLabel = [[UILabel alloc] init];
        _itemTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _itemTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _itemTitleLabel.backgroundColor = [UIColor clearColor];
        _itemTitleLabel.numberOfLines = 0;
        _itemTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_itemTitleLabel];
        
        self.qtyLabel = [[UILabel alloc] init];
        _qtyLabel.textColor = RGBCOLOR(57, 58, 70);
        _qtyLabel.font = [UIFont systemFontOfSize:14.0f];
        _qtyLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_qtyLabel];
        
        self.priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = RGBCOLOR(57, 58, 70);
        _priceLabel.font = [UIFont systemFontOfSize:14.0f];
        _priceLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_priceLabel];
        
        self.subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = RGBCOLOR(142, 142, 149);
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_subtitleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCartItemDict:(NSDictionary *)cartItemDict {
    _cartItemDict = cartItemDict;
    
    NSDictionary * product = cartItemDict[kShopCartItemProductKey];
    NSNumber * quantity = cartItemDict[kShopCartItemQuantityKey];
    
    _itemTitleLabel.text = product[@"name"];
    
    _subtitleLabel.text = [NSString stringWithFormat:@"Item Price: A$%.2f", [product[@"price"] floatValue]];
    _qtyLabel.text = [NSString stringWithFormat:@"%d", [quantity integerValue]];
    
    // Multiply price by quantity
    float rawPrice = [product[@"price"] floatValue];
    rawPrice = [quantity floatValue] * rawPrice;
    _priceLabel.text = [NSString stringWithFormat:@"A$%.2f", rawPrice];
    
    NSURL * thumbImageURL = [NSURL URLWithString:product[@"thumb"]];
    NSURLRequest * request = [NSURLRequest requestWithURL:thumbImageURL];
    __block ShopCartItemCell * blockCell = self;
    
    [self.cartItemImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        blockCell.cartItemImageView.image = image;
    } failure:nil];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cartItemImageContainerView.frame = CGRectMake(8.0f, 8.0f, 61.0f, 61.0f);
    self.cartItemImageView.frame = CGRectMake(3.0f, 3.0f, 55.0f, 55.0f);
    
    CGFloat imageHorizontalOffset = 8.0f + 61.0f + 12.0f;
    
    CGSize sizeForQuantityLabel = [self.qtyLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    _qtyLabel.frame = CGRectMake(imageHorizontalOffset, 8.0f, sizeForQuantityLabel.width, sizeForQuantityLabel.height);
    
    // Price is horizontally after title, but must be calculated first, so we know the width constraint of title label
    CGSize sizeForPriceLabel = [self.priceLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    _priceLabel.frame = CGRectMake(self.frame.size.width - 8.0f - sizeForPriceLabel.width, 8.0f, sizeForPriceLabel.width, sizeForPriceLabel.height);
    
    CGFloat widthConstraintForTitleLabel = self.frame.size.width - (imageHorizontalOffset + 8.0f + sizeForQuantityLabel.width + 12.0f + sizeForPriceLabel.width + 8.0f);
    CGSize sizeForItemTitleLabel = [self.itemTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(widthConstraintForTitleLabel, CGFLOAT_MAX)];
    _itemTitleLabel.frame = CGRectMake(imageHorizontalOffset + sizeForQuantityLabel.width + 12.0f, 8.0f, sizeForItemTitleLabel.width, sizeForItemTitleLabel.height);
    
    CGSize sizeForSubtitleLabel = [self.subtitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(widthConstraintForTitleLabel, CGFLOAT_MAX)];
    _subtitleLabel.frame = CGRectMake(imageHorizontalOffset + sizeForQuantityLabel.width + 12.0f, _itemTitleLabel.frame.origin.y + _itemTitleLabel.frame.size.height + 4.0f, sizeForSubtitleLabel.width, sizeForSubtitleLabel.height);
}

+ (CGFloat)heightForCellWithCartItem:(NSDictionary*)cartItem {
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat screenWidth = -1.0f;
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = applicationFrame.size.height;
    } else {
        screenWidth = applicationFrame.size.width;
    }
    
    NSDictionary * product = cartItem[kShopCartItemProductKey];
    NSNumber * quantity = cartItem[kShopCartItemQuantityKey];
    
    CGFloat imageHorizontalOffset = 8.0f + 61.0f + 12.0f;
    CGSize sizeForQuantityLabel = [[NSString stringWithFormat:@"%d", [quantity intValue]] sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    
    float price = [product[@"price"] floatValue] * [quantity floatValue];
    CGSize sizeForPriceLabel = [[NSString stringWithFormat:@"A$%.2f", price] sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    
    CGFloat widthConstraintForTitleLabel = screenWidth - (imageHorizontalOffset + 8.0f + sizeForQuantityLabel.width + 12.0f + sizeForPriceLabel.width + 8.0f);
    CGSize sizeForItemTitleLabel = [product[@"title"] sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(widthConstraintForTitleLabel, CGFLOAT_MAX)];
    
    NSString * subtitleString = [NSString stringWithFormat:@"Item Price: A$%.2f", [product[@"price"] floatValue]];
    CGSize sizeForSubtitleLabel = [subtitleString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(widthConstraintForTitleLabel, CGFLOAT_MAX)];
    
    // Returns the size of the container by comparing which of the title + subtitle + margins and image + margins is larger. One of these will always be the content that forces extension of the cell vertically
    CGFloat sizeForTitleAndSubtitleWithMargins = (8.0f + sizeForItemTitleLabel.height + 4.0f + sizeForSubtitleLabel.height + 8.0f);
    CGFloat sizeForImageWithMargins = (8.0f + 61.0f + 8.0f);
    
    return MAX(sizeForTitleAndSubtitleWithMargins, sizeForImageWithMargins);
}

@end
