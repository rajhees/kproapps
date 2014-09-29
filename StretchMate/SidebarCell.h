//
//  SidebarCell.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTableViewCell.h"

@interface SidebarCell : MMTableViewCell

@property (nonatomic, strong) NSString * titleForSection;
@property (nonatomic, strong) NSString * badgeNumber;

@end
