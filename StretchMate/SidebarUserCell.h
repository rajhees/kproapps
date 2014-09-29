//
//  SidebarUserCell.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarUserButton.h"

@protocol SidebarCellDelegate;
@interface SidebarUserCell : UITableViewCell

@property (nonatomic, strong) SidebarUserButton * userButton;
@property (nonatomic, assign) __unsafe_unretained id<SidebarCellDelegate> delegate;

@end

@protocol SidebarCellDelegate <NSObject>
- (void)userSidebarCell:(SidebarUserButton*)cell didTapUserButton:(UIButton*)userButton;
@end
