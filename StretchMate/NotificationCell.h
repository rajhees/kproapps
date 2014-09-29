//
//  NotificationCell.h
//  Exersite
//
//  Created by James Eunson on 4/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface NotificationCell : UITableViewCell

@property (nonatomic, strong) Notification * notification;

+ (CGFloat)heightForCellWithNotification:(Notification*)notification;

@end
