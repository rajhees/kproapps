//
//  LoginRegisterBlackButtonCell.m
//  Exersite
//
//  Created by James Eunson on 4/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginRegisterBlackButtonCell.h"

@interface LoginRegisterBlackButtonCell ()

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIImageView * selectedBackgroundImageView;

@end

@implementation LoginRegisterBlackButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            
            UIImage * backgroundImage = [[UIImage imageNamed:@"login-register-black-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 11, 9, 11)];
            self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
            _backgroundImageView.frame = CGRectMake(0, 8.0f, self.frame.size.width - 20.0f, 33.0f);
            
            [self.contentView addSubview:_backgroundImageView];
            
            UIImage * selectedBackgroundImage = [[UIImage imageNamed:@"login-register-black-button-selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 11, 9, 11)];
            self.selectedBackgroundImageView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
            _selectedBackgroundImageView.frame = CGRectMake(0, 8.0f, self.frame.size.width - 20.0f, 33.0f);
            _selectedBackgroundImageView.hidden = YES;
            [self.contentView addSubview:_selectedBackgroundImageView];
            
        } else {
            
            self.buttonHighlightedView = [[UIView alloc] init];
            [self.contentView addSubview:_buttonHighlightedView];
            [self.contentView sendSubviewToBack:_buttonHighlightedView];
            
            self.buttonBackgroundView = [[UIView alloc] init];
            [self.contentView addSubview:_buttonBackgroundView];
            [self.contentView sendSubviewToBack:_buttonBackgroundView];
            
            self.buttonHighlightedView.backgroundColor = RGBCOLOR(5, 140, 245);
            self.buttonHighlightedView.layer.cornerRadius = 4.0f;
            
//            self.buttonBackgroundView.backgroundColor = RGBCOLOR(40, 40, 40);
            self.buttonBackgroundView.backgroundColor = RGBCOLOR(116, 116, 116);
            self.buttonBackgroundView.layer.cornerRadius = 4.0f;
        }

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    
    if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        
        self.textLabel.shadowColor = [UIColor blackColor];
        self.textLabel.shadowOffset = CGSizeMake(0, -1.0f);
        
    } else {
        
        self.buttonBackgroundView.frame = CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, 33.0f);
        self.buttonHighlightedView.frame = CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, 33.0f);
    }
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.textLabel.frame = CGRectMake(0, 8.0f, self.frame.size.width, 33.0f);
    [self bringSubviewToFront:self.textLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        if(selected) {
            _selectedBackgroundImageView.alpha = 1.0f;
        } else {
            _selectedBackgroundImageView.alpha = 0.0f;
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
            _selectedBackgroundImageView.alpha = 1.0f;
        } else {
            _selectedBackgroundImageView.alpha = 0.0f;
        }
    } else {
        if(highlighted) {
            _buttonHighlightedView.alpha = 1.0f;
        } else {
            _buttonHighlightedView.alpha = 0.0f;
        }
    }
}

@end
