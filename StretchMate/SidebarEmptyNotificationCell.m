//
//  SidebarEmptyNotificationCell.m
//  Exersite
//
//  Created by James Eunson on 5/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "SidebarEmptyNotificationCell.h"

@implementation SidebarEmptyNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.text = @"No notifications to display.";
        self.textLabel.textColor = RGBCOLOR(119, 119, 119);
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return self;
}

@end
