//
//  LoginButtonCell.m
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "LoginButtonCell.h"

#define kLoginButtonImage @"login-button-bg"
#define kRegisterButtonImage @"login-register-button-bg"
#define kConfirmRegistrationButtonImage @"login-register-confirm-registration-button-bg"
#define kResetPasswordButtonImage @"login-register-reset-password-button-bg"

#define kLoginSelectedButtonImage @"login-button-bg-selected"
#define kRegisterSelectedButtonImage @"login-register-button-bg-selected"
#define kConfirmRegistrationSelectedButtonImage @"login-register-confirm-registration-button-bg-selected"
#define kResetPasswordSelectedButtonImage @"login-register-reset-password-button-bg"

@implementation LoginButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.buttonHighlightedView = [[UIView alloc] init];
        [self.contentView addSubview:_buttonHighlightedView];
        [self.contentView sendSubviewToBack:_buttonHighlightedView];
        
        self.buttonBackgroundView = [[UIView alloc] init];
        [self.contentView addSubview:_buttonBackgroundView];
        [self.contentView sendSubviewToBack:_buttonBackgroundView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (CGFloat)heightForCell {
    
    UIImageView * buttonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-button-bg"]];
    return buttonImageView.frame.size.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        if(selected) {
            _buttonHighlightedBackgroundView.alpha = 1.0f;
        } else {
            _buttonHighlightedBackgroundView.alpha = 0.0f;
        }
    } else {
        if(selected) {
            _buttonHighlightedView.alpha = 1.0f;
        } else {
            _buttonHighlightedView.alpha = 0.0f;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        if(highlighted) {
            _buttonHighlightedBackgroundView.alpha = 1.0f;
        } else {
            _buttonHighlightedBackgroundView.alpha = 0.0f;
        }
    } else {
        if(highlighted) {
            _buttonHighlightedView.alpha = 1.0f;
        } else {
            _buttonHighlightedView.alpha = 0.0f;
        }
    }
}

- (void)setType:(LoginButtonCellType)type {
    _type = type;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        NSString * filenameForType = nil;
        NSString * filenameForSelectedType = nil;
        
        if(type == LoginButtonCellTypeLogin) {
            
            filenameForType = kLoginButtonImage;
            filenameForSelectedType = kLoginSelectedButtonImage;
            
        } else if(type == LoginButtonCellTypeRegister) {
            
            filenameForType = kRegisterButtonImage;
            filenameForSelectedType = kRegisterSelectedButtonImage;
            
        } else if(type == LoginButtonCellTypeConfirmRegistration) {
            
            filenameForType = kConfirmRegistrationButtonImage;
            filenameForSelectedType = kConfirmRegistrationSelectedButtonImage;
            
        } else if(type == LoginButtonCellTypeResetPassword) {
            
            filenameForType = kResetPasswordButtonImage;
            filenameForSelectedType = kResetPasswordSelectedButtonImage;
        }
        
        self.buttonHighlightedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filenameForSelectedType]];
        _buttonHighlightedBackgroundView.frame = CGRectMake(8, 0, _buttonHighlightedBackgroundView.frame.size.width, _buttonHighlightedBackgroundView.frame.size.height);
        _buttonHighlightedBackgroundView.alpha = 0.0f;
        [self addSubview:self.buttonHighlightedBackgroundView];
        
        UIImageView * buttonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filenameForType]];
        buttonImageView.frame = CGRectMake(8, 0, buttonImageView.frame.size.width, buttonImageView.frame.size.height);
        [self addSubview:buttonImageView];
        
        [self bringSubviewToFront:_buttonHighlightedBackgroundView];
        
    } else {
        
        self.buttonHighlightedView.backgroundColor = RGBCOLOR(5, 140, 245);
        self.buttonHighlightedView.layer.cornerRadius = 4.0f;
        
        self.buttonBackgroundView.layer.cornerRadius = 4.0f;
        
        if(type == LoginButtonCellTypeLogin) {
//            self.buttonBackgroundView.backgroundColor = RGBCOLOR(40, 40, 40);
            self.buttonBackgroundView.backgroundColor = RGBCOLOR(116, 116, 116);            
        } else {
            self.buttonBackgroundView.backgroundColor = kTintColour;
        }
        
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Snap subviews to bottom of cell
    self.buttonBackgroundView.frame = CGRectMake(8.0f, self.frame.size.height - 44.0f, self.frame.size.width - 16.0f, 44.0f);
    self.buttonHighlightedView.frame = CGRectMake(8.0f, self.frame.size.height - 44.0f, self.frame.size.width - 16.0f, 44.0f);
    
    self.textLabel.frame = CGRectMake(0, self.frame.size.height - 44.0f, self.frame.size.width, 44.0f);
    
    [self bringSubviewToFront:self.textLabel];
}

@end
