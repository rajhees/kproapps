//
//  LoginPractitionerCell.m
//  Exersite
//
//  Created by James Eunson on 4/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginPractitionerCell.h"

@implementation LoginPractitionerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10.0f, 10.0f, 44.0f, 44.0f);
}

@end
