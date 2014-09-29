//
//  ProgramListingStartButton.m
//  Exersite
//
//  Created by James Eunson on 19/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramListingStartButton.h"

@implementation ProgramListingStartButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.startProgramLabel = [[UILabel alloc] init]; // WithFrame:CGRectMake(34, 0, startButton.frame.size.width - 34, startButton.frame.size.height)]
        _startProgramLabel.backgroundColor = [UIColor clearColor];
        _startProgramLabel.textColor = [UIColor whiteColor];
        _startProgramLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _startProgramLabel.text = @"Start this Program";
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            [self setImage:[UIImage imageNamed:@"program-start-program-button"] forState:UIControlStateNormal];
            
            _startProgramLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.35];
            _startProgramLabel.shadowOffset = CGSizeMake(0, -1);
            
            self.startIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"program-start-circle-icon"]];
            
        } else {
            
            self.backgroundColor = kTintColour;
            self.layer.cornerRadius = 4.0f;
            self.layer.masksToBounds = YES;
            
            self.startIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"program-start-circle-icon-ios7"]];
        }
        
        [self addSubview:_startIconImageView];
        [self addSubview:_startProgramLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _startProgramLabel.frame = CGRectMake(34, 0, self.frame.size.width - 34, self.frame.size.height);
    _startIconImageView.frame = CGRectMake(9, 8, _startIconImageView.frame.size.width, _startIconImageView.frame.size.height);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(169, 34);
}

@end
