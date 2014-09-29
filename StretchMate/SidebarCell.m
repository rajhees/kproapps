//
//  SidebarCell.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "SidebarCell.h"
#import "StretchMate.h"

#define kHighlightedCellGradient @[ (id)[RGBCOLOR(135, 45, 11) CGColor], (id)[RGBCOLOR(99, 26, 1) CGColor] ]
//#define kHighlightedCellGradient @[ (id)[RGBCOLOR(17, 22, 39) CGColor], (id)[RGBCOLOR(28, 36, 65) CGColor]]
//#define kSidebarUserBackgroundGradient @[ (id)[RGBCOLOR(135, 45, 11) CGColor], (id)[RGBCOLOR(99, 26, 1) CGColor] ]

@interface SidebarCell ()

@property (nonatomic, strong) UIView * sidebarBackgroundView;
@property (nonatomic, strong) CALayer * borderLayer;

@property (nonatomic, strong) CALayer * innerShadowBorderLayer;

@property (nonatomic, strong) CAGradientLayer * highlightLayer;

@property (nonatomic, strong) UIView * badgeAccessoryView;
@property (nonatomic, strong) UILabel * badgeAccessoryLabel;

@end

@implementation SidebarCell
@synthesize badgeAccessoryView = _badgeAccessoryView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setAccessoryCheckmarkColor:[UIColor whiteColor]];
        
        self.sidebarBackgroundView = [[UIView alloc] init];
        [_sidebarBackgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self setBackgroundView:_sidebarBackgroundView];
        
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        [self.textLabel setFont:[UIFont systemFontOfSize:16.0]];
        self.textLabel.textColor = RGBCOLOR(90, 90, 90);
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            self.borderLayer = [CALayer layer];
            [_borderLayer setBackgroundColor:RGBCOLOR(85, 85, 85).CGColor];
            _borderLayer.actions = @{@"colors": [NSNull null]};
            [self.layer insertSublayer:_borderLayer atIndex:1];
            
            self.highlightLayer = [CAGradientLayer layer];
            _highlightLayer.actions = @{@"opacity": [NSNull null]};
            _highlightLayer.colors = kHighlightedCellGradient;
            _highlightLayer.opacity = 0;
            [self.layer insertSublayer:_highlightLayer atIndex:3];
            
            [self.textLabel setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:.5]];
            [self.textLabel setShadowOffset:CGSizeMake(0, 1)];
        }
        
        self.innerShadowBorderLayer = [CALayer layer];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [_innerShadowBorderLayer setBackgroundColor:RGBCOLOR(35, 35, 35).CGColor];
        } else {
            [_innerShadowBorderLayer setBackgroundColor:RGBCOLOR(209, 209, 209).CGColor];
        }
        _innerShadowBorderLayer.actions = @{@"colors": [NSNull null]};
        [self.layer insertSublayer:_innerShadowBorderLayer atIndex:2];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            self.imageView.layer.borderColor = [RGBCOLOR(202, 202, 202) CGColor];
            self.imageView.layer.borderWidth = 1.0f;
            self.imageView.layer.cornerRadius = 5.0f;
        }
        
        self.badgeAccessoryView = [[UIView alloc] init];
        _badgeAccessoryView.backgroundColor = [UIColor whiteColor];
        _badgeAccessoryView.layer.cornerRadius = 4.0f;
        _badgeAccessoryView.layer.borderColor = [kTintColour CGColor];
        _badgeAccessoryView.layer.borderWidth = 1.0f;
        _badgeAccessoryView.hidden = YES;
        
        self.badgeAccessoryLabel = [[UILabel alloc] init];
        _badgeAccessoryLabel.font = [UIFont systemFontOfSize:16.0f];
        _badgeAccessoryLabel.backgroundColor = [UIColor clearColor];
        _badgeAccessoryLabel.textColor = kTintColour;
        _badgeAccessoryLabel.textAlignment = NSTextAlignmentCenter;
        [_badgeAccessoryView addSubview:_badgeAccessoryLabel];
        
        self.accessoryView = _badgeAccessoryView;
        
        [self setNeedsLayout];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
 
    CGSize sizeForBadgeLabel = [_badgeAccessoryLabel.text sizeWithFont:[UIFont systemFontOfSize:16.0f]];
    _badgeAccessoryLabel.frame = CGRectMake(0, 0, 40.0f, sizeForBadgeLabel.height + 10.0f);
    _badgeAccessoryView.frame = CGRectMake(self.frame.size.width - 40.0f - 8.0f, (self.frame.size.height / 2) - (_badgeAccessoryLabel.frame.size.height / 2), 40.0f, sizeForBadgeLabel.height + 10.0f);
    
    _sidebarBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [_borderLayer setFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    
    [_highlightLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 1)];
    [_innerShadowBorderLayer setFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
    
    self.imageView.frame = CGRectMake(10, 9.0f, self.imageView.frame.size.width, self.imageView.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected) {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            [_borderLayer setBackgroundColor:RGBCOLOR(11, 12, 18).CGColor];
            [_innerShadowBorderLayer setBackgroundColor:RGBCOLOR(17, 22, 39).CGColor];
            _highlightLayer.opacity = 1;
            self.sidebarBackgroundView.backgroundColor = RGBCOLOR(17, 22, 39);
            
        } else {
            [_innerShadowBorderLayer setBackgroundColor:RGBCOLOR(209, 209, 209).CGColor];
            self.sidebarBackgroundView.backgroundColor = kTintColour;
            self.textLabel.textColor = [UIColor whiteColor];
        }
        
    } else {
        
        self.sidebarBackgroundView.backgroundColor = RGBCOLOR(41, 48, 70);
        [_borderLayer setBackgroundColor:RGBCOLOR(63, 68, 82).CGColor];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            [_innerShadowBorderLayer setBackgroundColor:RGBCOLOR(35, 35, 35).CGColor];
            _highlightLayer.opacity = 0;
            
        } else {
            
            [_sidebarBackgroundView setBackgroundColor:RGBCOLOR(238, 238, 238)];
            [_innerShadowBorderLayer setBackgroundColor:RGBCOLOR(209, 209, 209).CGColor];
            self.textLabel.textColor = RGBCOLOR(90, 90, 90);
        }
    }
}

- (void)setTitleForSection:(NSString *)titleForSection {
    _titleForSection = titleForSection;
    
    self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sidebar-%@-icon", _titleForSection]];
}

- (void)setBadgeNumber:(NSString *)badgeNumber {
    _badgeNumber = badgeNumber;
    
    self.badgeAccessoryLabel.text = _badgeNumber;
    self.badgeAccessoryView.hidden = NO;
    
    [self setNeedsLayout];
}

@end
