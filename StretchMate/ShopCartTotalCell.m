//
//  ShopCartTotalCell.m
//  Exersite
//
//  Created by James Eunson on 6/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCartTotalCell.h"

@implementation ShopCartTotalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat textLabelWidth = roundf((self.frame.size.width - 16.0f) / 5) * 3; // 4/5 width, rounded to stop blurry misalignment problems, likewise below
    self.textLabel.frame = CGRectMake(8.0f, 0, textLabelWidth, self.frame.size.height);
    
    CGFloat detailTextLabelWidth = roundf((self.frame.size.width - 16.0f) / 5) * 2; // 1/5 width
    self.detailTextLabel.frame = CGRectMake(self.frame.size.width - detailTextLabelWidth - 8.0f, 0, detailTextLabelWidth, self.frame.size.height);
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
}

@end
