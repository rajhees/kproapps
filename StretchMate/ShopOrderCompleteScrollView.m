//
//  ShopOrderCompleteScrollView.m
//  Exersite
//
//  Created by James Eunson on 20/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopOrderCompleteScrollView.h"

#define kTitleText @"Order Placed"

#define kBodyText @"Your order has been placed. You will receive an email shortly confirming your payment and order contents, including all details of your shipment. Please check your spam filter if you do not receive this email.\n\nIf you have any questions about your order, please contact support from the settings section of the app. Thanks for shopping with Exersite!"

#define kCompleteImageHeight 124.0f

@interface ShopOrderCompleteScrollView ()
- (void)didTapOkButton:(id)sender;
@end

@implementation ShopOrderCompleteScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.completeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-checkout-complete-icon"]];
        [self addSubview:_completeImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = kTitleText;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        self.bodyMessageLabel = [[UILabel alloc] init];
        _bodyMessageLabel.text = kBodyText;
        _bodyMessageLabel.font = [UIFont systemFontOfSize:13.0f];
        _bodyMessageLabel.textColor = RGBCOLOR(99, 100, 109);
        _bodyMessageLabel.backgroundColor = [UIColor clearColor];
        _bodyMessageLabel.numberOfLines = 0;
        _bodyMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_bodyMessageLabel];
        
        self.okBigButton = [[ShopBigButton alloc] init];
        _okBigButton.type = ShopBigButtonTypeOKGotIt;
        [_okBigButton addTarget:self action:@selector(didTapOkButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_okBigButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
 
    _completeImageView.frame = CGRectMake((self.frame.size.width / 2) - (_completeImageView.frame.size.width / 2), 35.0f, _completeImageView.frame.size.width, _completeImageView.frame.size.height);
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.titleLabel.frame = CGRectMake(8, _completeImageView.frame.origin.y + _completeImageView.frame.size.height + 20.0f, self.frame.size.width - 16.0f, sizeForTitleLabel.height);
    
    CGSize sizeForBodyMessageLabel = [self.bodyMessageLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _bodyMessageLabel.frame = CGRectMake(8.0f, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 8.0f, self.frame.size.width - 16.0f, sizeForBodyMessageLabel.height);
    
    _okBigButton.frame = CGRectMake(8.0f, _bodyMessageLabel.frame.origin.y + _bodyMessageLabel.frame.size.height + 20.0f, self.frame.size.width - 16.0f, 44.0f);
    
    self.contentSize = CGSizeMake(self.frame.size.width, [[self class] heightForScrollView]);
}

+ (CGFloat)heightForScrollView {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 35.0f; // Baseline top margin
    
    heightAccumulator += kCompleteImageHeight;
    
    heightAccumulator += (20.0f + [kTitleText sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]].height);
    heightAccumulator += (8.0f + [kBodyText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    
    heightAccumulator += (20.0f + 44.0f + 20.0f); // incl. 20 units bottom padding
    
    return heightAccumulator;
}

#pragma mark - Private Methods
- (void)didTapOkButton:(id)sender {
    
    if([self.orderCompleteDelegate respondsToSelector:@selector(shopOrderCompleteScrollView:didTapOkButton:)]) {
        [self.orderCompleteDelegate performSelector:@selector(shopOrderCompleteScrollView:didTapOkButton:) withObject:self withObject:sender];
    }
}

@end
