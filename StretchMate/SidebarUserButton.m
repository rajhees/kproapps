//
//  SidebarUserButton.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "SidebarUserButton.h"
#import "ExersiteSession.h"

#define kLoginString @"Login to Exersite"
#define kLoginSubtitleString @"Tap to Login"

#define kHighlightedCellGradient @[ (id)[RGBCOLOR(5, 140, 245) CGColor], (id)[RGBCOLOR(1, 93, 230) CGColor] ]

@interface SidebarUserButton ()

@property (nonatomic, strong) CALayer * lightBorderLayer;
@property (nonatomic, strong) CALayer * darkBorderLayer;

@property (nonatomic, strong) UIView * highlightView;

@property (nonatomic, strong) CALayer * bottomBorder;

- (void)didTapButtonDown:(id)sender;

@end

@implementation SidebarUserButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            CAGradientLayer * itemHighlightLayer = [CAGradientLayer layer];
            
            [itemHighlightLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            itemHighlightLayer.actions = @{@"opacity": [NSNull null]};
            itemHighlightLayer.colors = kHighlightedCellGradient;
            [_highlightView.layer insertSublayer:itemHighlightLayer atIndex:0];
            
        } else {
            
            _highlightView.backgroundColor = RGBCOLOR(5, 140, 245);
        }
        _highlightView.alpha = 0.0f;
        _highlightView.userInteractionEnabled = NO;
        
        [self addSubview:_highlightView];
        
        UIView * userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kUserButtonWidth, 44)];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [userView addSubview:_nameLabel];
        
        self.roleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_roleLabel setBackgroundColor:[UIColor clearColor]];
        [_roleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [userView addSubview:_roleLabel];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            [_nameLabel setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:.5]];
            [_nameLabel setShadowOffset:CGSizeMake(0, 1)];
            [_nameLabel setTextColor:[UIColor whiteColor]];
            
            [_roleLabel setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:.5]];
            [_roleLabel setShadowOffset:CGSizeMake(0, 1)];
            [_roleLabel setTextColor:RGBCOLOR(137, 140, 150)];
            
        } else {
            
            _nameLabel.textColor = RGBCOLOR(90, 90, 90);
            _roleLabel.textColor = RGBCOLOR(142, 142, 149);
        }
        
        self.imagePlaceholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebar-user-icon-ios7"]];
        _imagePlaceholderView.frame = CGRectMake(10, 10, _imagePlaceholderView.frame.size.width, _imagePlaceholderView.frame.size.height);
        [self addSubview:_imagePlaceholderView];
        
        userView.userInteractionEnabled = NO;
        [self addSubview:userView];
        
        [self updateUserInformation];
        
        [self addTarget:self action:@selector(didTapButtonDown:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForNameLabel = [_nameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(135.0f, 25) lineBreakMode:NSLineBreakByTruncatingTail];
    _nameLabel.frame = CGRectMake(53, 4, sizeForNameLabel.width, sizeForNameLabel.height);
    
    CGSize sizeForRoleLabel = [_roleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(135.0f, 25) lineBreakMode:NSLineBreakByTruncatingTail];
    _roleLabel.frame = CGRectMake(53, sizeForNameLabel.height+2, sizeForRoleLabel.width, sizeForRoleLabel.height);
    
    _imagePlaceholderView.frame = CGRectMake(10, 10, 26, 27);
    _userPortraitImageView.frame = CGRectMake(0, 0, 26, 27);
    
    _lightBorderLayer.frame = CGRectMake(kUserButtonWidth - 1, 0, 1, self.frame.size.height);
    _darkBorderLayer.frame = CGRectMake(kUserButtonWidth - 2, 0, 1, self.frame.size.height);
    
    _highlightView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Private Methods
- (void)didTapButtonDown:(id)sender {
    _highlightView.alpha = 1.0f;
    
    _nameLabel.textColor = [UIColor whiteColor];
    _roleLabel.textColor = [UIColor whiteColor];
}

- (void)deselectUserButton {
    [UIView animateWithDuration:0.5f animations:^{
        _highlightView.alpha = 0.0f;
    }];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_roleLabel setTextColor:RGBCOLOR(137, 140, 150)];
    } else {
        _nameLabel.textColor = RGBCOLOR(90, 90, 90);
        _roleLabel.textColor = RGBCOLOR(142, 142, 149);
    }
}

- (void)updateUserInformation {
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        
        _nameLabel.text = [[ExersiteSession currentSession] userFullName];
        NSString * roleForUserTypeString = [[ExersiteSession currentSession] roleForUserType];
        _roleLabel.text = roleForUserTypeString;
        
    } else {
        
        _nameLabel.text = kLoginString;
        _roleLabel.text = kLoginSubtitleString;
    }
    
    [self setNeedsLayout];
}

@end
