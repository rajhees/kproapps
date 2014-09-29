//
//  ShopBuyButton.m
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopBuyButton.h"
#import "ProgressHUDHelper.h"

static NSString * confirmString = @"Confirm?";

@interface ShopBuyButton()
- (void)didTapSelf:(id)sender;
@end

@implementation ShopBuyButton

- (id)initWithFrame:(CGRect)frame price:(NSString*)priceString
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentState = BuyButtonStateNormal;
        
        UIImage * buyContainerImage = [[UIImage imageNamed:@"shop-stretchable-buy-container"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 46)];
        self.buyContainerView = [[UIImageView alloc] initWithImage:buyContainerImage];
        self.buyContainerView.frame = CGRectMake(0, 0, 0, _buyContainerView.frame.size.height);
        
        [self addSubview:_buyContainerView];
        
        self.buyIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-buy-icon"]];
        _buyIconView.frame = CGRectMake(frame.size.width - _buyIconView.frame.size.width - 5, 7, _buyIconView.frame.size.width, _buyIconView.frame.size.height);
        [self addSubview:self.buyIconView];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.text = priceString;
        _priceLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.textAlignment = UITextAlignmentCenter;
        _priceLabel.shadowColor = RGBCOLOR(116, 57, 15);
        _priceLabel.shadowOffset = CGSizeMake(0, -1.0f);
        [self addSubview:self.priceLabel];
        
        self.shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _shadeView.layer.cornerRadius = 5.0f;
        _shadeView.backgroundColor = [UIColor blackColor];
        _shadeView.alpha = 0.0f;
        _shadeView.userInteractionEnabled = NO;
        [self addSubview:_shadeView];
        
        [self addTarget:self action:@selector(didTapSelf:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (CGFloat)widthForPrice:(NSString*)priceString {
    
    CGSize priceStringSize = [priceString sizeWithFont:[UIFont boldSystemFontOfSize:19.0f]];
    CGFloat buyContainerWidth = priceStringSize.width + 5.0f + 46.0f + 5.0f; // 5 extra padding
    return buyContainerWidth;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if(highlighted) {
        _shadeView.alpha = 0.3f;
    } else {
        _shadeView.alpha = 0.0f;
    }
}

- (void)setPriceString:(NSString *)priceString {
    _priceString = priceString;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect currentFrame = self.frame;
//    NSLog(@"currentFrame width: %f", currentFrame.size.width);
    
    CGSize priceStringSize = CGSizeZero;
    if(self.currentState == BuyButtonStateNormal) {
        
        priceStringSize = [self.priceString sizeWithFont:[UIFont boldSystemFontOfSize:19.0f]];
        CGFloat totalWidth = priceStringSize.width + 5.0f + 46.0f + 5.0f; // 5 extra padding
        self.frame = CGRectMake((304 - 14) - totalWidth, self.frame.origin.y, totalWidth, 37.0f);
        
    } else {
        
        priceStringSize = [confirmString sizeWithFont:[UIFont boldSystemFontOfSize:15.0f]];
        CGFloat totalWidth = priceStringSize.width + 5.0f + 46.0f + 5.0f; // 5 extra padding
        self.frame = CGRectMake((304 - 14) - totalWidth, self.frame.origin.y, totalWidth, 37.0f);
    }
    
    CGFloat buyContainerWidth = priceStringSize.width + 5.0f + 46.0f + 5.0f;
    
    self.buyContainerView.frame = CGRectMake(0, 0, buyContainerWidth, _buyContainerView.frame.size.height);
    _buyIconView.frame = CGRectMake(_buyContainerView.frame.size.width - _buyIconView.frame.size.width - 5, 7, _buyIconView.frame.size.width, _buyIconView.frame.size.height);
    
    self.priceLabel.frame = CGRectMake(3, (self.frame.size.height - priceStringSize.height)/2, priceStringSize.width+5.0f, priceStringSize.height);
    self.shadeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setCurrentState:(BuyButtonState)currentState {
    
    _currentState = currentState;
    
    if(currentState == BuyButtonStateAwaitingConfirmation) {
        
        self.priceLabel.text = confirmString;
        self.priceLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        
    } else if(currentState == BuyButtonStateConfirmed) {

        self.priceLabel.text = @"In Cart";
        self.priceLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    
    [self setNeedsLayout];    
}

- (void)didTapSelf:(id)sender {
    
    if(self.currentState == BuyButtonStateNormal) {
        self.currentState = BuyButtonStateAwaitingConfirmation;
    } else if(self.currentState == BuyButtonStateAwaitingConfirmation) {
        [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"tick"] withLabelText:@"Added to Cart" withDetailsLabelText:nil withFadeTime:1.0f];
        self.currentState = BuyButtonStateConfirmed;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
