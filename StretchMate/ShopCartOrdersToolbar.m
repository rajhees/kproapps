//
//  ShopCartOrdersToolbar.m
//  Exersite
//
//  Created by James Eunson on 22/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCartOrdersToolbar.h"

@interface ShopCartOrdersToolbar()

@property (nonatomic, strong, readonly) UIButton * ordersButton;
@property (nonatomic, strong, readonly) UIButton * cartButton;

@property (nonatomic, strong) UILabel * cartBadgeLabel; // Has to be accessible to be updated

- (void)didTapOrdersButton:(id)sender;
- (void)didTapCartButton:(id)sender;

@end

@implementation ShopCartOrdersToolbar

@synthesize ordersButton = _ordersButton;
@synthesize cartButton = _cartButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.barTintColor = [UIColor whiteColor];
        self.translucent = YES;
        
        [self addSubview:self.cartButton];
        
        [self addSubview:self.ordersButton];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_cartButton, _ordersButton);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_cartButton]-6-|" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_ordersButton]-6-|" options:0 metrics:nil views:bindings]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[_cartButton]-12-[_ordersButton(==_cartButton)]-6-|" options:0 metrics:nil views:bindings]];
    }
    return self;
}

- (UIButton*)ordersButton {
    
    if(_ordersButton) {
        return _ordersButton;
    }
    
    _ordersButton = [[UIButton alloc] init];
    _ordersButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_ordersButton addTarget:self action:@selector(didTapOrdersButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * ordersImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-orders-icon-ios7"]];
    ordersImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_ordersButton addSubview:ordersImageView];
    
    _ordersButton.layer.borderColor = [RGBCOLOR(201, 201, 201) CGColor];
    _ordersButton.layer.borderWidth = 1.0f;
    _ordersButton.layer.cornerRadius = 4.0f;
    
    UILabel * ordersLabel = [[UILabel alloc] init];
    
    ordersLabel.font = [UIFont systemFontOfSize:14.0f];
    ordersLabel.text = @"Orders";
    ordersLabel.backgroundColor = [UIColor clearColor];
    ordersLabel.textColor = RGBCOLOR(150, 150, 156);
    ordersLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_ordersButton addSubview:ordersLabel];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(ordersImageView, ordersLabel);
    
    [_ordersButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ordersLabel]|" options:0 metrics:nil views:bindings]];
    [_ordersButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[ordersImageView(19)]-13-|" options:0 metrics:nil views:bindings]];
    [_ordersButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[ordersImageView]-10-[ordersLabel]" options:0 metrics:nil views:bindings]];
    
    return _ordersButton;
}

- (UIButton*)cartButton {
    
    if(_cartButton) {
        return _cartButton;
    }
    
    // Generate standard cart button with icon
    _cartButton = [[UIButton alloc] init];
    _cartButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cartButton addTarget:self action:@selector(didTapCartButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView * cartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-cart-icon-ios7"]];
    cartImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_cartButton addSubview:cartImageView];
    
    _cartButton.layer.borderColor = [RGBCOLOR(201, 201, 201) CGColor];
    _cartButton.layer.borderWidth = 1.0f;
    _cartButton.layer.cornerRadius = 4.0f;
    
    UILabel * cartButtonLabel = [[UILabel alloc] init];
    
    cartButtonLabel.font = [UIFont systemFontOfSize:14.0f];
    cartButtonLabel.text = @"Cart";
    cartButtonLabel.backgroundColor = [UIColor clearColor];
    cartButtonLabel.textColor = RGBCOLOR(150, 150, 156);
    cartButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_cartButton addSubview:cartButtonLabel];
    
    // Generate badge number view, indicating how many items are currently in the user's cart
    self.cartBadgeView = [[UIView alloc] init];
    _cartBadgeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _cartBadgeView.layer.cornerRadius = 4.0f;
    _cartBadgeView.layer.masksToBounds = YES;
    _cartBadgeView.backgroundColor = kTintColour;
    
    self.cartBadgeLabel = [[UILabel alloc] init];
    
    _cartBadgeLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _cartBadgeLabel.textColor = [UIColor whiteColor];
    _cartBadgeLabel.textAlignment = NSTextAlignmentCenter;
    _cartBadgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _cartBadgeLabel.backgroundColor = [UIColor clearColor];
    
    [_cartBadgeView addSubview:_cartBadgeLabel];
    [_cartButton addSubview:_cartBadgeView];
    
    _cartBadgeView.hidden = YES;
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(cartImageView, cartButtonLabel, _cartBadgeView);
    
    [_cartButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cartButtonLabel]|" options:0 metrics:nil views:bindings]];
    [_cartButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[cartImageView(22)]" options:0 metrics:nil views:bindings]];
    [_cartButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_cartBadgeView(28)]-8-|" options:0 metrics:nil views:bindings]];
    
    [_cartButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[cartImageView]-10-[cartButtonLabel]" options:0 metrics:nil views:bindings]];
    [_cartButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_cartBadgeView(32)]-8-|" options:0 metrics:nil views:bindings]];
    
    [_cartBadgeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cartBadgeLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cartBadgeLabel)]];
    [_cartBadgeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cartBadgeLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cartBadgeLabel)]];
    
    return _cartButton;
}

- (void)updateCartValue {
    
    NSInteger numberOfProductsInCart = [[[AppConfig sharedConfig] shopCartItems] count];
    if(numberOfProductsInCart == 0) {
        _cartBadgeView.hidden = YES;
    } else {
        _cartBadgeView.hidden = NO;
        _cartBadgeLabel.text = [NSString stringWithFormat:@"%d", numberOfProductsInCart];
    }
}

#pragma mark - Private Methods
- (void)didTapOrdersButton:(id)sender {
    if([self.cartOrdersDelegate respondsToSelector:@selector(shopCartOrdersToolbar:didTapOrdersButton:)]) {
        [self.cartOrdersDelegate performSelector:@selector(shopCartOrdersToolbar:didTapOrdersButton:) withObject:self withObject:sender];
    }
}

- (void)didTapCartButton:(id)sender {
    if([self.cartOrdersDelegate respondsToSelector:@selector(shopCartOrdersToolbar:didTapCartButton:)]) {
        [self.cartOrdersDelegate performSelector:@selector(shopCartOrdersToolbar:didTapCartButton:) withObject:self withObject:sender];
    }
}

@end
