//
//  OrangeSectionHeaderView.m
//  StretchMate
//
//  Created by James Eunson on 29/11/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "OrangeSectionHeaderView.h"

@implementation OrangeSectionHeaderView

- (id)initWithFrame:(CGRect)frame text:(NSString*)text
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView * instructionHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-detail-header-bg"]];
        [self addSubview:instructionHeaderView];
        
        UILabel * instructionHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, instructionHeaderView.frame.size.width-13, instructionHeaderView.frame.size.height)];
        instructionHeaderLabel.backgroundColor = [UIColor clearColor];
        instructionHeaderLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        instructionHeaderLabel.text = text;
        instructionHeaderLabel.textColor = RGBCOLOR(255, 255, 255);
        instructionHeaderLabel.shadowColor = RGBCOLOR(108, 5, 0);
        instructionHeaderLabel.shadowOffset = CGSizeMake(0, -1.0f);
        [instructionHeaderView addSubview:instructionHeaderLabel];
        
        [self addSubview:instructionHeaderLabel];
    }
    return self;
}

@end
