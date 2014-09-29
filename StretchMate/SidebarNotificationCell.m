//
//  SidebarNotificationCell.m
//  Exersite
//
//  Created by James Eunson on 4/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "SidebarNotificationCell.h"
#import "NSDate+TimeAgo.h"
#import "AppDelegate.h"

@interface SidebarNotificationCell ()

@property (nonatomic, strong) CALayer * bottomBorderLayer;

@property (nonatomic, strong) UIView * unreadIndicator;

@end

@implementation SidebarNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = [UIFont systemFontOfSize:13.0f];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textColor = RGBCOLOR(90, 90, 90);
        
        self.backgroundColor = RGBCOLOR(238, 238, 238);
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        self.detailTextLabel.textColor = RGBCOLOR(160, 160, 160);
        
        self.bottomBorderLayer = [CALayer layer];
        _bottomBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_bottomBorderLayer atIndex:100];
        
        self.unreadIndicator = [[UIView alloc] init];
        _unreadIndicator.layer.cornerRadius = 4.0f;
        _unreadIndicator.backgroundColor = RGBCOLOR(5, 140, 245);
        [self addSubview:_unreadIndicator];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForMessage = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.textLabel.frame = CGRectMake(8.0f + 8.0f + 8.0f, 8.0f, self.frame.size.width - 16.0f, sizeForMessage.height);
    
    CGSize sizeForSubtitle = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
    self.detailTextLabel.frame = CGRectMake(8.0f + 8.0f + 8.0f, self.textLabel.frame.origin.y + self.textLabel.frame.size.height, self.frame.size.width, sizeForSubtitle.height);
    
    _unreadIndicator.frame = CGRectMake(8.0f, 12.0f, 8.0f, 8.0f);
    
    _bottomBorderLayer.frame = CGRectMake(0, self.frame.size.height - 1.0f, self.frame.size.width, 1.0f);
}

- (void)setNotification:(Notification *)notification {
    _notification = notification;
    
    self.textLabel.text = _notification.message;
    self.detailTextLabel.text = [_notification timeAgoString];
    
    if([_notification.read boolValue]) {
        _unreadIndicator.backgroundColor = RGBCOLOR(203, 203, 203);
    } else {
        _unreadIndicator.backgroundColor = RGBCOLOR(5, 140, 245);
    }
    
    [self setNeedsLayout];
}

+ (CGFloat)heightForNotificationCellWithNotification:(Notification *)notification {
    
    CGFloat heightAccumulator = 0;
    CGSize sizeForMessage = [notification.message sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(kSidebarWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    heightAccumulator += 8 + sizeForMessage.height;
    
    CGSize sizeForSubtitle = [notification.timeAgoString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(kSidebarWidth - 16.0f, CGFLOAT_MAX)];
    heightAccumulator += sizeForSubtitle.height + 8.0f;
    
    return heightAccumulator;
}

@end
