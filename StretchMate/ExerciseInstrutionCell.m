//
//  ExerciseInstrutionCell.m
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseInstrutionCell.h"

#define kCellWidth 302.0f

#define kBackgroundGradientColors @[ (id)[RGBCOLOR(255, 255, 255) CGColor], (id)[RGBCOLOR(225, 225, 225) CGColor] ]
#define kCurrentlySelectedGradientColors @[ (id)[RGBCOLOR(208, 123, 48) CGColor], (id)[RGBCOLOR(162, 66, 0) CGColor] ]

@interface ExerciseInstrutionCell()
+ (CGFloat)heightForLabelWithExerciseInstructionString:(NSString*)exerciseInstructionString;
@end

@implementation ExerciseInstrutionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
         
            self.backgroundGradientLayer = [CAGradientLayer layer];
            _backgroundGradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-2);
            _backgroundGradientLayer.colors = kBackgroundGradientColors;
            [self.contentView.layer insertSublayer:self.backgroundGradientLayer atIndex:0];
         
            self.numberBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-instruction-number-bg"]];
            _numberBackgroundView.frame = CGRectMake(15, 6, _numberBackgroundView.frame.size.width, _numberBackgroundView.frame.size.height);
            [self addSubview:self.numberBackgroundView];
            
        } else {
            
            self.flatNumberBackgroundView = [[UIView alloc] init];
            _flatNumberBackgroundView.backgroundColor = RGBCOLOR(149, 149, 142);
            _flatNumberBackgroundView.layer.cornerRadius = 14.0f;
            [self addSubview:_flatNumberBackgroundView];
            
            self.flatHighlightView = [[UIView alloc] init];
            _flatHighlightView.backgroundColor = kTintColour;
            _flatHighlightView.hidden = YES;
            [self addSubview:_flatHighlightView];
        }
        
        self.numberLabel = [[UILabel alloc] init];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.text = @"1";
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            _numberLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.75f];
            _numberLabel.shadowOffset = CGSizeMake(0, -1.0f);
        }
        
        [_flatNumberBackgroundView addSubview:self.numberLabel];
    }
    return self;
}

- (void)setExerciseInstructionString:(NSString *)exerciseInstructionString {
    
    _exerciseInstructionString = exerciseInstructionString;
    self.textLabel.text = self.exerciseInstructionString;
    
    [super setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat labelHeight = [[self class] heightForLabelWithExerciseInstructionString:self.exerciseInstructionString];
    
    self.textLabel.font = [UIFont systemFontOfSize:13.0f];
    self.textLabel.frame = CGRectMake(55, 8.0f, self.frame.size.width-65, labelHeight);
    
    self.textLabel.numberOfLines = 0;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.backgroundGradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-2);
    
    self.flatHighlightView.frame = CGRectMake(0, 0, 3.0f, self.frame.size.height);
    
    if(!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        _flatNumberBackgroundView.frame = CGRectMake(8.0f, 8.0f, 28, 28);
        self.numberLabel.frame = CGRectMake(0, 0, _flatNumberBackgroundView.frame.size.width, _flatNumberBackgroundView.frame.size.width);
    } else {
        self.numberLabel.frame = CGRectMake(0, 0, _numberBackgroundView.frame.size.width, _numberBackgroundView.frame.size.width);
    }
}

+ (CGFloat)heightWithExerciseInstructionString:(NSString*)exerciseInstructionString {
    return MAX(44.0f, ([[self class] heightForLabelWithExerciseInstructionString:exerciseInstructionString] + 15.0f)); // 5 px top margin and 10px bottom margin
}

+ (CGFloat)heightForLabelWithExerciseInstructionString:(NSString*)exerciseInstructionString {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat labelWidth = screenWidth - 65.0f;
    CGSize instructionSize = [exerciseInstructionString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(labelWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    return instructionSize.height + 8.0f;
}

- (void)setCurrentSelectedCell:(BOOL)currentSelectedCell {
    _currentSelectedCell = currentSelectedCell;
    
    if(currentSelectedCell) {
        
        if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            self.textLabel.textColor = RGBCOLOR(255, 255, 255);
            
            self.textLabel.shadowOffset = CGSizeMake(0, -1.0f);
            self.textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
            _numberLabel.textColor = RGBCOLOR(156, 78, 24);
            
            self.numberBackgroundView.image = [UIImage imageNamed:@"exercise-selected-instruction-number-bg"];
            
            _backgroundGradientLayer.colors = kCurrentlySelectedGradientColors;
            
        } else {
            
            _flatNumberBackgroundView.backgroundColor = kTintColour;
            _flatHighlightView.hidden = NO;
        }
        
    } else {
        
        if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
         
            _backgroundGradientLayer.colors = kBackgroundGradientColors;
            
            self.textLabel.textColor = RGBCOLOR(65, 65, 65);
            self.textLabel.shadowOffset = CGSizeMake(0, 1.0f);
            self.textLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
            
            _numberLabel.textColor = [UIColor whiteColor];
            
            self.numberBackgroundView.image = [UIImage imageNamed:@"exercise-instruction-number-bg"];
            
        } else {
            
            _flatNumberBackgroundView.backgroundColor = RGBCOLOR(142, 142, 149);
            _flatHighlightView.hidden = YES;
        }
    }
}

@end
