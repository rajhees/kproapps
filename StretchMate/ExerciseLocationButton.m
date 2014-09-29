//
//  ExerciseLocationButton.m
//  Exersite
//
//  Created by James Eunson on 1/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseLocationButton.h"
#import "Exercise.h"

@interface ExerciseLocationButton ()

@property (nonatomic, strong) UIView * highlightView;

- (void)didTouchDown:(id)sender;
- (void)didTouchUp:(id)sender;

@end

@implementation ExerciseLocationButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage * resizableAnnotationBoxImage = nil;
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            resizableAnnotationBoxImage = [[UIImage imageNamed:@"anatomy-annotation-box"] resizableImageWithCapInsets:UIEdgeInsetsMake(23, 16, 23, 16)];
        } else {
            resizableAnnotationBoxImage = [[UIImage imageNamed:@"anatomy-annotation-box-ios7"] resizableImageWithCapInsets:UIEdgeInsetsMake(23, 16, 23, 16)];
        }
        
        self.backgroundImageView = [[UIImageView alloc] initWithImage:resizableAnnotationBoxImage];
        _backgroundImageView.layer.borderWidth = 1.0f;
        _backgroundImageView.layer.borderColor = [RGBCOLOR(180, 180, 180) CGColor];
        _backgroundImageView.layer.cornerRadius = 22.0f;
        
        [self addSubview:_backgroundImageView];
        
        self.highlightView = [[UIView alloc] init];
        _highlightView.alpha = 0.0f;
        _highlightView.userInteractionEnabled = NO;
        _highlightView.backgroundColor = RGBCOLOR(5, 140, 245);
        _highlightView.layer.cornerRadius = 22.0f;
        [self addSubview:_highlightView];
        
        self.locationInfoImageView = [[UIImageView alloc] init];
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            [_locationInfoImageView setImage:[UIImage imageNamed:@"anatomy-annotation-icon"]];
        } else {
            [_locationInfoImageView setImage:[UIImage imageNamed:@"anatomy-annotation-icon-ios7"]];
        }
        [_locationInfoImageView sizeToFit];
        [self addSubview:_locationInfoImageView];
        
        self.locationLabelTextView = [[UILabel alloc] init];
        _locationLabelTextView.backgroundColor = [UIColor clearColor];
        _locationLabelTextView.numberOfLines = 0;
        _locationLabelTextView.lineBreakMode = NSLineBreakByWordWrapping;
        _locationLabelTextView.font = [UIFont systemFontOfSize:13.0f];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            _locationLabelTextView.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
            _locationLabelTextView.shadowOffset = CGSizeMake(0, -1);
            _locationLabelTextView.textColor = [UIColor whiteColor];
        } else {
            _locationLabelTextView.textColor = RGBCOLOR(51, 51, 51);
        }
        
        [self addSubview:_locationLabelTextView];
        
        [self addTarget:self action:@selector(didTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundImageView.frame = CGRectMake(0, 0, 117, self.frame.size.height);
    _highlightView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CGRect locationInfoButtonRect = CGRectNull;
    CGFloat locationButtonVerticalOffset = (self.frame.size.height / 2) - 15;
    
    if(self.frame.origin.x < 370) { // LHS
        locationInfoButtonRect = CGRectMake(77, locationButtonVerticalOffset, 30, 30);
    } else { // RHS
        locationInfoButtonRect = CGRectMake(8, locationButtonVerticalOffset, 30, 30);
    }
    _locationInfoImageView.frame = locationInfoButtonRect;
    
    CGSize sizeForLabel = [_key sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(65, CGFLOAT_MAX)];
    
    CGRect locationLabelTextRect = CGRectNull;
    CGFloat labelVerticalOffset = (self.frame.size.height / 2) - (sizeForLabel.height / 2);
    if(self.frame.origin.x < 370) { // LHS
        locationLabelTextRect = CGRectMake(6, labelVerticalOffset, 65, sizeForLabel.height);
    } else {
        locationLabelTextRect = CGRectMake(44, labelVerticalOffset, 65, sizeForLabel.height);
    }
    _locationLabelTextView.frame = locationLabelTextRect;
    
    if(self.frame.origin.x < 370) { // LHS
        _locationLabelTextView.textAlignment = NSTextAlignmentRight;
    }
}

+ (CGFloat)heightForButtonWithTitle:(NSString*)title {
    
    CGSize sizeForLabel = [title sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(65, CGFLOAT_MAX)];
    CGFloat buttonHeight = MAX(46, (sizeForLabel.height + 16));
    
    return buttonHeight;
}

#pragma mark - Property Override
- (void)setKey:(NSString *)key {
    _key = key;
    
    self.tag = [kExerciseLocationLookupHash[_key] intValue];
    self.locationLabelTextView.text = key;
    
    [self setNeedsLayout];
}

#pragma mark - Private Methods
- (void)didTouchDown:(id)sender {
    
    _highlightView.alpha = 1.0f;
    _locationLabelTextView.textColor = [UIColor whiteColor];
}

- (void)didTouchUp:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        _highlightView.alpha = 0.0f;
    }];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        _locationLabelTextView.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
        _locationLabelTextView.shadowOffset = CGSizeMake(0, -1);
        _locationLabelTextView.textColor = [UIColor whiteColor];
    } else {
        _locationLabelTextView.textColor = RGBCOLOR(51, 51, 51);
    }
}

@end
