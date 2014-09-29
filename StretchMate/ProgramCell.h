//
//  ProgramCell.h
//  Exersite
//
//  Created by James Eunson on 4/07/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"

@interface ProgramCell : UITableViewCell

@property (nonatomic, strong) NSDictionary * programDict;
@property (nonatomic, strong) Program * program;

@end
