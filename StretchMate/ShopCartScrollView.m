//
//  ShopCartScrollView.m
//  Exersite
//
//  Created by James Eunson on 5/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCartScrollView.h"
#import "ShopCartItemCell.h"
#import "ShopCartTotalCell.h"

#define kCartCellReuseIdentifier @"cartItemCell"
#define kCartTotalCellReuseIdentifier @"cartTotalCell"

#define kEmptyImageViewWidth 150.0f
#define kEmptyImageViewHeight 162.0f

@interface ShopCartScrollView ()
//- (CGFloat)heightForTableView;

- (void)didTapCheckoutButton:(id)sender;
- (void)didTapRequestQuoteButton:(id)sender;
@end

@implementation ShopCartScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = @"My Cart";
        [self addSubview:_titleLabel];
        
        self.itemsCountLabel = [[UILabel alloc] init];
        
        _itemsCountLabel.font = [UIFont systemFontOfSize:14.0f];
        _itemsCountLabel.textColor = RGBCOLOR(142, 142, 149);
        _itemsCountLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_itemsCountLabel];
        
        self.cartItemsTableView = [[ShopCartTableView alloc] initWithType:ShopCartTableViewTypeNormal];
        _cartItemsTableView.shopCartTableDelegate = self;
        
        _cartItemsTableView.separatorInset = UIEdgeInsetsZero;
        _cartItemsTableView.scrollEnabled = NO;
        
        [_cartItemsTableView registerClass:[ShopCartItemCell class] forCellReuseIdentifier:kCartCellReuseIdentifier];
        [_cartItemsTableView registerClass:[ShopCartTotalCell class] forCellReuseIdentifier:kCartTotalCellReuseIdentifier];
        
        [self addSubview:_cartItemsTableView];
        
        self.cartItemsTableViewTopBorder = [CALayer layer];
        [_cartItemsTableViewTopBorder setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_cartItemsTableViewTopBorder];
        
        self.cartItemsTableViewBottomBorder = [CALayer layer];
        [_cartItemsTableViewBottomBorder setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_cartItemsTableViewBottomBorder];
        
        self.checkoutButton = [[ShopBigButton alloc] init];
        _checkoutButton.type = ShopBigButtonTypeCheckoutNow;
        [_checkoutButton addTarget:self action:@selector(didTapCheckoutButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkoutButton];
        
        self.deliveringOutsideAustraliaTitleLabel = [[UILabel alloc] init];
        _deliveringOutsideAustraliaTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _deliveringOutsideAustraliaTitleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _deliveringOutsideAustraliaTitleLabel.backgroundColor = [UIColor clearColor];
        _deliveringOutsideAustraliaTitleLabel.text = @"Delivering outside Australia?";
        [self addSubview:_deliveringOutsideAustraliaTitleLabel];
        
        self.deliveringOutsideAustraliaBorderLayer = [CALayer layer];
        [_deliveringOutsideAustraliaBorderLayer setBackgroundColor:RGBCOLOR(203, 203, 203).CGColor];
        [self.layer addSublayer:_deliveringOutsideAustraliaBorderLayer];
        
        self.deliveringOutsideAustraliaBodyLabel = [[UILabel alloc] init];
        _deliveringOutsideAustraliaBodyLabel.font = [UIFont systemFontOfSize:13.0f];
        _deliveringOutsideAustraliaBodyLabel.textColor = RGBCOLOR(99, 100, 109);
        _deliveringOutsideAustraliaBodyLabel.backgroundColor = [UIColor clearColor];
        _deliveringOutsideAustraliaBodyLabel.numberOfLines = 0;
        _deliveringOutsideAustraliaBodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _deliveringOutsideAustraliaBodyLabel.text = @"If you are ordering from outside Australia, please request a delivery quote before you place your order, using the button below.";
        [self addSubview:_deliveringOutsideAustraliaBodyLabel];
        
        self.requestQuoteButton = [[ShopBigButton alloc] init];
        _requestQuoteButton.type = ShopBigButtonTypeRequestDeliveryQuote;
        [_requestQuoteButton addTarget:self action:@selector(didTapRequestQuoteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_requestQuoteButton];
        
        self.emptyViewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-cart-empty-icon-ios7"]];
        _emptyViewImageView.hidden = YES;
        [self addSubview:_emptyViewImageView];
        
        self.emptyViewTitleLabel = [[UILabel alloc] init];
        _emptyViewTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _emptyViewTitleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _emptyViewTitleLabel.backgroundColor = [UIColor clearColor];
        _emptyViewTitleLabel.text = @"You have no items in your cart";
        _emptyViewTitleLabel.textAlignment = NSTextAlignmentCenter;
        _emptyViewTitleLabel.hidden = YES;
        [self addSubview:_emptyViewTitleLabel];
        
        self.emptyViewSubtitleLabel = [[UILabel alloc] init];
        _emptyViewSubtitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _emptyViewSubtitleLabel.textColor = [UIColor grayColor];
        _emptyViewSubtitleLabel.backgroundColor = [UIColor clearColor];
        _emptyViewSubtitleLabel.numberOfLines = 0;
        _emptyViewSubtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _emptyViewSubtitleLabel.text = @"Press “Add to Cart” on a product page and the product will appear here.";
        _emptyViewSubtitleLabel.textAlignment = NSTextAlignmentCenter;
        _emptyViewSubtitleLabel.hidden = YES;
        [self addSubview:_emptyViewSubtitleLabel];
        
        [self updateContent];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.titleLabel.frame = CGRectMake(8, 12, sizeForTitleLabel.width, sizeForTitleLabel.height);
    
    CGSize sizeForItemsCountLabel = [self.itemsCountLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    self.itemsCountLabel.frame = CGRectMake(self.frame.size.width - 8.0f - sizeForItemsCountLabel.width, 12.0f, sizeForItemsCountLabel.width, sizeForItemsCountLabel.height);
    
    [_cartItemsTableViewTopBorder setFrame:CGRectMake(0, _itemsCountLabel.frame.origin.y + _itemsCountLabel.frame.size.height + 19.0f, self.frame.size.width, 1)];
    
    // If no items in cart, don't even bother laying out item-related UI elements, only layout empty view
    if([[[AppConfig sharedConfig] shopCartItems] count] == 0) {
        
        CGFloat subtitleLabelConstrainedWidth = ((self.frame.size.width / 5) * 4) - 16.0f;
        
        CGFloat heightForImageView = _emptyViewImageView.frame.size.height;
        CGFloat widthForImageView = _emptyViewImageView.frame.size.width;
        
        // Reduce image size to 65% of normal proportions, if horizontal orientation
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            
            heightForImageView = kEmptyImageViewHeight * 0.65f;
            widthForImageView = kEmptyImageViewWidth * 0.65f;
            
        } else {
            
            heightForImageView = kEmptyImageViewHeight;
            widthForImageView = kEmptyImageViewWidth;
        }
        
        CGSize sizeForEmptyViewTitleLabel = [_emptyViewTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
        CGSize sizeForEmptyViewSubtitleLabel = [_emptyViewSubtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(subtitleLabelConstrainedWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        // Vertically center in space defined by top border and bottom of the screen
        CGFloat emptyViewContentHeight = (heightForImageView + 20.0f + sizeForEmptyViewTitleLabel.height + sizeForEmptyViewSubtitleLabel.height);
        CGFloat startingPoint = ((self.frame.size.height - (_cartItemsTableViewTopBorder.frame.origin.y + 1.0f)) / 2) - (emptyViewContentHeight / 2) + _cartItemsTableViewTopBorder.frame.origin.y;
        
        _emptyViewImageView.frame = CGRectMake((self.frame.size.width / 2) - (widthForImageView / 2), startingPoint, widthForImageView, heightForImageView);
        
        _emptyViewTitleLabel.frame = CGRectMake(8.0f, _emptyViewImageView.frame.origin.y + _emptyViewImageView.frame.size.height + 20.0f, self.frame.size.width - 16.0f, sizeForEmptyViewTitleLabel.height);
        
        _emptyViewSubtitleLabel.frame = CGRectMake((self.frame.size.width / 2) - (sizeForEmptyViewSubtitleLabel.width / 2), _emptyViewTitleLabel.frame.origin.y + _emptyViewTitleLabel.frame.size.height + 4.0f, sizeForEmptyViewSubtitleLabel.width, sizeForEmptyViewSubtitleLabel.height);
        
    } else {
     
        [self.cartItemsTableView reloadData];        
        
        CGFloat heightForTableView = [ShopCartTableView heightForTableView];
        self.cartItemsTableView.frame = CGRectMake(0, _itemsCountLabel.frame.origin.y + _itemsCountLabel.frame.size.height + 20.0f, self.frame.size.width, heightForTableView);
        
        [_cartItemsTableViewBottomBorder setFrame:CGRectMake(0, _cartItemsTableView.frame.origin.y + _cartItemsTableView.frame.size.height, self.frame.size.width, 1)];
        
        self.checkoutButton.frame = CGRectMake(8.0f, self.cartItemsTableView.frame.origin.y + self.cartItemsTableView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
        
        CGSize sizeForDeliveringOutsideAustraliaTitleLabel = [self.deliveringOutsideAustraliaTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
        self.deliveringOutsideAustraliaTitleLabel.frame = CGRectMake(8.0f, self.checkoutButton.frame.origin.y + self.checkoutButton.frame.size.height + 30.0f, sizeForDeliveringOutsideAustraliaTitleLabel.width, sizeForDeliveringOutsideAustraliaTitleLabel.height);
        
        [_deliveringOutsideAustraliaBorderLayer setFrame:CGRectMake(0, _deliveringOutsideAustraliaTitleLabel.frame.origin.y + _deliveringOutsideAustraliaTitleLabel.frame.size.height + 8.0f, self.frame.size.width, 1)];
        
        CGSize sizeForDeliveringOutsideAustraliaBodyLabel = [self.deliveringOutsideAustraliaBodyLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
        self.deliveringOutsideAustraliaBodyLabel.frame = CGRectMake(8.0f, self.deliveringOutsideAustraliaBorderLayer.frame.origin.y + self.deliveringOutsideAustraliaBorderLayer.frame.size.height + 8.0f, sizeForDeliveringOutsideAustraliaBodyLabel.width, sizeForDeliveringOutsideAustraliaBodyLabel.height);
        
        _requestQuoteButton.frame = CGRectMake(8.0f, _deliveringOutsideAustraliaBodyLabel.frame.origin.y + _deliveringOutsideAustraliaBodyLabel.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
    }
}

// Calculate the vertical contentSize of this UIScrollView subclass, based on the current screen width
+ (CGFloat)containerHeightForCartScrollView {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat cartScrollViewHeightAccumulator = 0;
    
    CGSize sizeForTitleLabel = [@"My Cart" sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    cartScrollViewHeightAccumulator += (12.0f + sizeForTitleLabel.height + 20.0f);
    
    // cartItemTableView height
    cartScrollViewHeightAccumulator += (3 * 33.0f);
    for(NSDictionary * cartItem in [[AppConfig sharedConfig] shopCartItems]) {
        cartScrollViewHeightAccumulator += [ShopCartItemCell heightForCellWithCartItem:cartItem];
    }
    
    cartScrollViewHeightAccumulator += 8.0f + 44.0f + 30.0f;
    CGSize sizeForDeliveringOutsideAustraliaTitleLabel = [@"Delivering outside Australia?" sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
    cartScrollViewHeightAccumulator += sizeForDeliveringOutsideAustraliaTitleLabel.height + 8.0f + 1.0f + 8.0f;
    
    CGSize sizeForDeliveringOutsideAustraliaBodyLabel = [@"If you are ordering from outside Australia, please request a delivery quote before you place your order, using the button below." sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
    cartScrollViewHeightAccumulator += sizeForDeliveringOutsideAustraliaBodyLabel.height + 8.0f + 44.0f + 20.0f; // 20.0f padding at the bottom
    
    return cartScrollViewHeightAccumulator;
}

- (void)updateContent {
    
    // Show empty view, if user has no products in their cart
    if([[[AppConfig sharedConfig] shopCartItems] count] == 0) {
        
        _cartItemsTableViewBottomBorder.hidden = YES;
        _cartItemsTableView.hidden = YES;
        _checkoutButton.hidden = YES;
        _deliveringOutsideAustraliaTitleLabel.hidden = YES;
        _deliveringOutsideAustraliaBorderLayer.hidden = YES;
        _deliveringOutsideAustraliaBodyLabel.hidden = YES;
        _requestQuoteButton.hidden = YES;

        _emptyViewImageView.hidden = NO;
        _emptyViewTitleLabel.hidden = NO;
        _emptyViewSubtitleLabel.hidden = NO;
        
    } else {
        
        _cartItemsTableViewBottomBorder.hidden = NO;
        _cartItemsTableView.hidden = NO;
        _checkoutButton.hidden = NO;
        _deliveringOutsideAustraliaTitleLabel.hidden = NO;
        _deliveringOutsideAustraliaBorderLayer.hidden = NO;
        _deliveringOutsideAustraliaBodyLabel.hidden = NO;
        _requestQuoteButton.hidden = NO;
        
        _emptyViewImageView.hidden = YES;
        _emptyViewTitleLabel.hidden = YES;
        _emptyViewSubtitleLabel.hidden = YES;
    }
    
    NSArray * items = [[AppConfig sharedConfig] shopCartItems];
    NSString * itemString = (([items count] > 1 || [items count] == 0) ? @"items" : @"item"); // pluralization
    _itemsCountLabel.text = [NSString stringWithFormat:@"%d %@", [items count], itemString];
    
    [self.cartItemsTableView reloadData];
    [self setNeedsLayout];
}

#pragma mark - ShopCartTableViewDelegate Methods
- (void)shopCartTableView:(ShopCartTableView*)shopCartTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
    NSDictionary * itemForRow = [[AppConfig sharedConfig] shopCartItems][indexPath.row];

    if([self.cartDelegate respondsToSelector:@selector(shopCartScrollView:didSelectCartItem:)]) {
        [self.cartDelegate performSelector:@selector(shopCartScrollView:didSelectCartItem:) withObject:self withObject:itemForRow];
    }
}

- (void)shopCartTableView:(ShopCartTableView*)shopCartTableView didCommitEditStyleForRowAtIndexPath:(NSIndexPath*)indexPath {
    [self updateContent];

    if([self.cartDelegate respondsToSelector:@selector(shopCartScrollView:didRemoveCartItemFromTableView:)]) {
        [self.cartDelegate performSelector:@selector(shopCartScrollView:didRemoveCartItemFromTableView:) withObject:self withObject:self.cartItemsTableView];
    }
}

#pragma mark - Private Methods
- (void)didTapCheckoutButton:(id)sender {
//    NSLog(@"didTapCheckoutButton:");
    
    if([self.cartDelegate respondsToSelector:@selector(shopCartScrollView:didTapCheckoutButton:)]) {
        [self.cartDelegate performSelector:@selector(shopCartScrollView:didTapCheckoutButton:) withObject:self withObject:sender];
    }
}

- (void)didTapRequestQuoteButton:(id)sender {
//    NSLog(@"didTapRequestQuoteButton:");
    
    if([self.cartDelegate respondsToSelector:@selector(shopCartScrollView:didTapRequestQuoteButton:)]) {
        [self.cartDelegate performSelector:@selector(shopCartScrollView:didTapRequestQuoteButton:) withObject:self withObject:sender];
    }
}

@end
