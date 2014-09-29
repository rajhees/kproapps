//
//  PrescriptionProgramExerciseCell.m
//  Exersite
//
//  Created by James Eunson on 14/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionProgramExerciseCell.h"

@implementation PrescriptionProgramExerciseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.textLabel.textColor = [UIColor grayColor];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(self.imageView.image) {
        
        self.imageView.frame = CGRectMake(0, 0, 55.0f, 33.0f);
        self.textLabel.frame = CGRectMake(63.0f, self.textLabel.frame.origin.y, self.frame.size.width - 63.0f - 16.0f, self.textLabel.frame.size.height);
        
    } else {
        
        self.textLabel.frame = CGRectMake(22, self.textLabel.frame.origin.y, self.frame.size.width - 22.0f - 16.0f, self.textLabel.frame.size.height);
    }
}

@end
