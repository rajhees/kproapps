//
//  NotificationCell.m
//  Exersite
//
//  Created by James Eunson on 4/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = [UIFont systemFontOfSize:13.0f];
        self.textLabel.textColor = kTintColour;
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textAlignment = NSTextAlignmentRight;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        self.detailTextLabel.textColor = RGBCOLOR(90, 90, 90);
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTextLabel = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake((self.frame.size.width / 4) - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.textLabel.frame = CGRectMake(8.0f, 8.0f, MAX(sizeForTextLabel.width, ((self.frame.size.width / 4) - 16.0f) ), sizeForTextLabel.height);
    
    CGSize sizeForDetailTextLabel = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(((self.frame.size.width / 4) * 3) - 24.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.detailTextLabel.frame = CGRectMake(8.0f + self.textLabel.frame.size.width + 16.0f, 8.0f, sizeForDetailTextLabel.width, sizeForDetailTextLabel.height);
}

+ (CGFloat)heightForCellWithNotification:(Notification*)notification {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGSize sizeForTextLabel = [notification.timeAgoString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake((screenWidth / 4) - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize sizeForDetailTextLabel = [notification.message sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake((3 * (screenWidth / 4)) - 24.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    return MAX((16.0f + sizeForTextLabel.height), 16.0f + sizeForDetailTextLabel.height);
}

#pragma mark - Property Override
- (void)setNotification:(Notification *)notification {
    _notification = notification;
    
    self.textLabel.text = notification.timeAgoString;
    self.detailTextLabel.text = notification.message;

    
    [self setNeedsLayout];
    
    if(![notification.read boolValue]) {
        [notification markAsRead];
    }
}

@end
