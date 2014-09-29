//
//  LoginRegisterHeaderView.m
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginRegisterHeaderView.h"

@interface LoginRegisterHeaderView ()

@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) UIImageView * highlightBackgroundView;

@end

@implementation LoginRegisterHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Underlay
        if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            self.highlightBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-register-highlight-background"]];
            [self addSubview:_highlightBackgroundView];
        }

        // Labels + image, overlay
        self.headingLabel = [[UILabel alloc] init];
        
        self.headingLabel.backgroundColor = [UIColor clearColor];
        self.headingLabel.font = [UIFont boldSystemFontOfSize:24.0f];
        self.headingLabel.textColor = RGBCOLOR(41, 41, 41);
        
        if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            _headingLabel.shadowColor = [UIColor whiteColor];
            _headingLabel.shadowOffset = CGSizeMake(0, 1.0f);
        }
        
        [self addSubview:_headingLabel];
        
        self.subHeadingLabel = [[UILabel alloc] init];
        
        self.subHeadingLabel.backgroundColor = [UIColor clearColor];
        self.subHeadingLabel.font = [UIFont systemFontOfSize:13.0f];
        self.subHeadingLabel.textColor = RGBCOLOR(105, 105, 105);
        self.subHeadingLabel.numberOfLines = 0;
        self.subHeadingLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            _subHeadingLabel.shadowColor = [UIColor whiteColor];
            _subHeadingLabel.shadowOffset = CGSizeMake(0, 1.0f);
        }
        
        [self addSubview:_subHeadingLabel];
        
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
        [self addSubview:_iconImageView];
        
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.iconImageView.frame = CGRectMake(8.0f, 0, _iconImageView.frame.size.width, _iconImageView.frame.size.height);
    
    if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.highlightBackgroundView.frame = CGRectMake(0, self.frame.size.height - _highlightBackgroundView.frame.size.height, _highlightBackgroundView.frame.size.width, _highlightBackgroundView.frame.size.height);
    }
        
    CGFloat textMaxWidth = (self.frame.size.width - (8.0f * 2) - _iconImageView.frame.size.width);
    CGFloat textSideOffset = (8.0f + _iconImageView.frame.size.width + 8.0f);
    
    CGSize sizeForHeadingLabel = [self.headingLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:24.0f] constrainedToSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)];
    self.headingLabel.frame = CGRectMake(textSideOffset, -3.0f, sizeForHeadingLabel.width, sizeForHeadingLabel.height); // -3.0f to compensate for in-built padding to get baseline alignment
    
    // Subheading is intended to span multiple lines, main heading only one
    CGSize sizeForSubHeadingLabel = [self.subHeadingLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.subHeadingLabel.frame = CGRectMake(textSideOffset, sizeForHeadingLabel.height - 3.0f, sizeForSubHeadingLabel.width, sizeForSubHeadingLabel.height); // -3.0f to compensate for in-built padding to get baseline alignment
}

+ (CGFloat)heightForHeaderViewWithTitle:(NSString*)title andSubtitle:(NSString*)subtitle {
    
    CGFloat screenWidth = -1.0f;
    CGFloat heightAccumulator = 8.0f + 8.0f;
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat textMaxWidth = (screenWidth - (8.0f * 2) - 57.0f);
    
    CGSize sizeForHeadingLabel = [title sizeWithFont:[UIFont boldSystemFontOfSize:24.0f] constrainedToSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX)];
    heightAccumulator += sizeForHeadingLabel.height;
    
    // Subheading is intended to span multiple lines, main heading only one
    CGSize sizeForSubHeadingLabel = [subtitle sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(textMaxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    heightAccumulator += sizeForSubHeadingLabel.height;
    
    CGFloat minimumIconSize = (57.0f + 8.0 + 8.0f);
    return MAX(heightAccumulator, minimumIconSize);
}

@end
