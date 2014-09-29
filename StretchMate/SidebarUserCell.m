//
//  SidebarUserCell.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

//#define kSidebarUserBackgroundGradient @[ (id)[RGBCOLOR(135, 45, 11) CGColor], (id)[RGBCOLOR(99, 26, 1) CGColor] ]
#define kSidebarUserBackgroundGradient @[ (id)[RGBCOLOR(35, 40, 58) CGColor], (id)[RGBCOLOR(16, 21, 38) CGColor] ]

#import "SidebarUserCell.h"

@interface SidebarUserCell ()

@property (nonatomic, strong) CAGradientLayer * backgroundGradientLayer;
@property (nonatomic, strong) CALayer * bottomBorder;

- (void)didTapUserButton:(UIButton*)sender;
@end

@implementation SidebarUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            self.userButton = [[SidebarUserButton alloc] initWithFrame:CGRectMake(0, 0, kUserButtonWidth, 44)];
            
            self.backgroundGradientLayer = [CAGradientLayer layer];
            _backgroundGradientLayer.colors = kSidebarUserBackgroundGradient;
            _backgroundGradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, 44);
            [self.layer insertSublayer:_backgroundGradientLayer atIndex:0];
            
            CALayer * borderLayer = [CALayer layer];
            [borderLayer setBackgroundColor:RGBCOLOR(63, 68, 82).CGColor];
            [borderLayer setFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
            [self.layer insertSublayer:borderLayer above:_backgroundGradientLayer];
            
        } else {
            
            self.userButton = [[SidebarUserButton alloc] initWithFrame:CGRectMake(0, 20, kUserButtonWidth, 44)];
//            self.backgroundColor = RGBCOLOR(35, 40, 58);
            self.backgroundColor = [UIColor whiteColor];
            
            self.bottomBorder = [CALayer layer];
            [_bottomBorder setBackgroundColor:RGBCOLOR(209, 209, 209).CGColor];
            [self.layer insertSublayer:_bottomBorder atIndex:100];
        }
        
        [_userButton addTarget:self action:@selector(didTapUserButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_userButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bottomBorder.frame = CGRectMake(0, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f);
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.userButton.frame = CGRectMake(0, 0, kUserButtonWidth, 44);
    } else {
        self.userButton.frame = CGRectMake(0, 20, self.frame.size.width, 44);
    }
}

#pragma mark - Private Methods
- (void)didTapUserButton:(UIButton*)sender {
    
    if([self.delegate respondsToSelector:@selector(userSidebarCell:didTapUserButton:)]) {
        [self.delegate performSelector:@selector(userSidebarCell:didTapUserButton:) withObject:self withObject:sender];
    }
}

@end
