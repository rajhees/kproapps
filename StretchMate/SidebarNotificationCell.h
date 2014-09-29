//
//  SidebarNotificationCell.h
//  Exersite
//
//  Created by James Eunson on 4/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface SidebarNotificationCell : UITableViewCell

@property (nonatomic, strong) Notification * notification;

+ (CGFloat)heightForNotificationCellWithNotification:(Notification*)notification;

@end
