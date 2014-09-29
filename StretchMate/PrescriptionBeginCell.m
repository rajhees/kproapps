//
//  PrescriptionBeginCell.m
//  Exersite
//
//  Created by James Eunson on 5/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionBeginCell.h"

@implementation PrescriptionBeginCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.textColor = kTintColour;
        self.textLabel.font = [UIFont systemFontOfSize:16.0f];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(70, 0, self.frame.size.width - 70.0f, self.frame.size.height);
}

- (void)setHourString:(NSString *)hourString {
    _hourString = hourString;
    
    self.textLabel.text = [NSString stringWithFormat:@"Begin %@ Exercises", _hourString];
    [self setNeedsLayout];
}

- (void)setAllCompleted:(BOOL)allCompleted {
    _allCompleted = allCompleted;
    
    if(allCompleted) {
//        self.textLabel.text = [NSString stringWithFormat:@"%@ Exercises Complete", _hourString];
        self.textLabel.text = @"Exercises Complete";
        
        self.textLabel.textColor = [UIColor grayColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        
        self.textLabel.textColor = kTintColour;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}

@end
