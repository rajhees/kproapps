//
//  RemoteImageOverlayInformationView.m
//  MyMonash
//
//  Created by James Eunson on 25/10/2013.
//  Copyright (c) 2013 JEON. All rights reserved.
//

#import "RemoteImageOverlayInformationView.h"

#define kTitleFont [UIFont boldSystemFontOfSize: 15.0f]
#define kSubtitleFont [UIFont systemFontOfSize: 13.0f]

@interface RemoteImageOverlayInformationView ()

- (void)didTapShareButton:(id)sender;

@end

@implementation RemoteImageOverlayInformationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel = [[UILabel alloc] init];
        
        _titleLabel.font = kTitleFont;
        _titleLabel.textColor = RGBCOLOR(51, 51, 51);
        
        [self addSubview:_titleLabel];
        
        self.subtitleLabel = [[UILabel alloc] init];
        
        _subtitleLabel.font = kSubtitleFont;
        _subtitleLabel.textColor = RGBCOLOR(101, 101, 101);
        
        [self addSubview:_subtitleLabel];
        
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"remote-image-view-icon"]];
        _iconImageView.alpha = 0.4f;
        [self addSubview:_iconImageView];
        
        self.shareButton = [[UIButton alloc] init];
        [_shareButton setImage:[UIImage imageNamed:@"remote-image-view-share-icon"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(didTapShareButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
        
        self.barTintColor = [UIColor whiteColor];
        self.translucent = YES;
        
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconImageView.frame = CGRectMake(10.0f, 8.0f, _iconImageView.frame.size.width, _iconImageView.frame.size.height);
    
    CGSize textConstraintSize = CGSizeMake(self.frame.size.width - 20.0f - self.iconImageView.frame.size.width - 10.0f - 30.0f, 20.0f);
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:kTitleFont constrainedToSize:textConstraintSize lineBreakMode:NSLineBreakByTruncatingTail];
    CGSize sizeForSubtitleLabel = [self.subtitleLabel.text sizeWithFont:kSubtitleFont constrainedToSize:textConstraintSize lineBreakMode:NSLineBreakByTruncatingTail];
    
    self.titleLabel.frame = CGRectMake(10.0f + self.iconImageView.frame.size.width + 10.0f, 6.0f, sizeForTitleLabel.width, sizeForTitleLabel.height);
    self.subtitleLabel.frame = CGRectMake(10.0f + self.iconImageView.frame.size.width + 10.0f, sizeForTitleLabel.height + 6.0f + 4.0f, sizeForSubtitleLabel.width, sizeForSubtitleLabel.height);
    
    self.shareButton.frame = CGRectMake(self.frame.size.width - 10.0f - 21.0f, (self.frame.size.height / 2) - (28.0f / 2), 21.0f, 28.0f);
}

- (CGSize)intrinsicContentSize {
    
    CGSize textConstraintSize = CGSizeMake(self.frame.size.width - 20.0f - self.iconImageView.frame.size.width - 10.0f - 30.0f, 20.0f);
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:kTitleFont constrainedToSize:textConstraintSize lineBreakMode:NSLineBreakByTruncatingTail];
    CGSize sizeForSubtitleLabel = [self.subtitleLabel.text sizeWithFont:kSubtitleFont constrainedToSize:textConstraintSize lineBreakMode:NSLineBreakByTruncatingTail];
    
    // 2 * 6.0f top and bottom padding, 1 * 4.0f in-between padding
    CGFloat requiredHeight = sizeForTitleLabel.height + sizeForSubtitleLabel.height + (2 * 6.0f) + 4.0f;
    
//    NSLog(@"intrinsicContentSize height: %f, output height: %f", requiredHeight, MAX(self.iconImageView.frame.size.height + 10.0f, requiredHeight));
    
    return CGSizeMake(UIViewNoIntrinsicMetric, MAX(self.iconImageView.frame.size.height + 10.0f, requiredHeight));
}

#pragma mark - Private Methods
- (void)didTapShareButton:(id)sender {
    
    if([self.overlayDelegate respondsToSelector:@selector(overlayInformationView:didTapShareButton:)]) {
        [self.overlayDelegate performSelector:@selector(overlayInformationView:didTapShareButton:) withObject:self withObject:sender];
    }
}

@end
