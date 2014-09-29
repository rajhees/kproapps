//
//  ProgramDescriptionCell.m
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramDescriptionCell.h"

@implementation ProgramDescriptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:13.0f];
        self.textLabel.textColor = RGBCOLOR(90, 90, 90);
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)setProgram:(Program *)program {
    _program = program;
    
    self.textLabel.text = [_program programDescription];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTextLabel = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.textLabel.frame = CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f, sizeForTextLabel.height);
}

+ (CGFloat)heightWithProgram:(Program*)program {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    CGSize sizeForTextLabel = [program.programDescription sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return sizeForTextLabel.height + 16.0f;
}

+ (CGFloat)heightWithString:(NSString *)string {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    CGSize sizeForTextLabel = [string sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return sizeForTextLabel.height + 16.0f;
}

@end
