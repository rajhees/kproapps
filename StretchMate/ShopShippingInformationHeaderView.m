//
//  ShopShippingInformationHeaderView.m
//  Exersite
//
//  Created by James Eunson on 21/10/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopShippingInformationHeaderView.h"

@interface ShopShippingInformationHeaderView ()
- (void)didTapRequestQuoteButton:(id)sender;
@end

@implementation ShopShippingInformationHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage * resizableBackgroundImage = [[UIImage imageNamed:@"shop-shipping-information-header-bg-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, self.frame.size.width - 1)];
        self.backgroundImageView = [[UIImageView alloc] initWithImage:resizableBackgroundImage];
        [self addSubview:_backgroundImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        NSAttributedString *titleAttributedString = [[NSAttributedString alloc] initWithString:@"$10 Flat Rate shipping in Australia" attributes: @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0f], NSForegroundColorAttributeName : [UIColor whiteColor], NSKernAttributeName : @(-0.5f) }];
        _titleLabel.attributedText = titleAttributedString;
        
        [self addSubview:self.titleLabel];
        
        self.subtitleLabel = [[UILabel alloc] init];
        
        NSAttributedString *subtitleAttributedString = [[NSAttributedString alloc] initWithString:@"International shipping available by request." attributes: @{ NSFontAttributeName : [UIFont systemFontOfSize:14.0f], NSForegroundColorAttributeName : [UIColor whiteColor], NSKernAttributeName : @(-0.5f) }];
        _subtitleLabel.attributedText = subtitleAttributedString;
        
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.alpha = 0.8f;
        
        [self addSubview:self.subtitleLabel];
        
        self.requestQuoteButton = [[UIButton alloc] init];
        
        [_requestQuoteButton addTarget:self action:@selector(didTapRequestQuoteButton:) forControlEvents:UIControlEventTouchUpInside];
        _requestQuoteButton.layer.cornerRadius = 4.0f;
        _requestQuoteButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _requestQuoteButton.layer.borderWidth = 1.0f;
        _requestQuoteButton.alpha = 0.8f;
        
        self.requestQuoteButtonLabel = [[UILabel alloc] init];
        
        NSAttributedString * buttonAttributedString = [[NSAttributedString alloc] initWithString:@"Request a quote" attributes: @{ NSFontAttributeName : [UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName : [UIColor whiteColor], NSKernAttributeName : @(-0.5f) }];
        _requestQuoteButtonLabel.textAlignment = NSTextAlignmentLeft;
        _requestQuoteButtonLabel.attributedText = buttonAttributedString;
        
        [_requestQuoteButton addSubview:_requestQuoteButtonLabel];
        
        self.requestQuoteButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-shipping-information-header-button-arrow-ios7"]];
        [_requestQuoteButton addSubview:_requestQuoteButtonImageView];
        
        [self addSubview:_requestQuoteButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // This isn't completely accurate due to attributed string, but we only want height not width anyway, so size calculations are not really affected
    
    _backgroundImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CGSize sizeForTitleLabel = [_titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:15.0f]];
    _titleLabel.frame = CGRectMake(10, 10, self.frame.size.width, sizeForTitleLabel.height);
    
    CGSize sizeForSubtitleLabel = [_subtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    _subtitleLabel.frame = CGRectMake(10, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 2.0f, self.frame.size.width, sizeForSubtitleLabel.height);
    
    _requestQuoteButton.frame = CGRectMake(10, _subtitleLabel.frame.origin.y + _subtitleLabel.frame.size.height + 10.0f, (self.frame.size.width / 2) - 10.0f, 26.0f);
    _requestQuoteButtonLabel.frame = CGRectMake(6, 0, _requestQuoteButton.frame.size.width - 6.0f, _requestQuoteButton.frame.size.height);
    _requestQuoteButtonImageView.frame = CGRectMake(_requestQuoteButton.frame.size.width - _requestQuoteButtonImageView.frame.size.width - 6.0f, 6, _requestQuoteButtonImageView.frame.size.width, _requestQuoteButtonImageView.frame.size.height);
}

#pragma mark - Private Methods
- (void)didTapRequestQuoteButton:(id)sender {
    
//    NSLog(@"Request Quote button tapped");
    if([self.delegate respondsToSelector:@selector(shopShippingInformationHeader:didSelectRequestQuoteButton:)]) {
        [self.delegate performSelector:@selector(shopShippingInformationHeader:didSelectRequestQuoteButton:) withObject:self withObject:sender];
    }
}

@end
