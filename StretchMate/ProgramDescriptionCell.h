//
//  ProgramDescriptionCell.h
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"

@interface ProgramDescriptionCell : UITableViewCell

@property (nonatomic, strong) Program * program;

+ (CGFloat)heightWithProgram:(Program*)program;

// Allows arbitrary text to be fed into cell, as called from ExercisesListingViewController
+ (CGFloat)heightWithString:(NSString*)string;

@end
