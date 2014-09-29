//
//  ExerciseLocationButton.h
//  Exersite
//
//  Created by James Eunson on 1/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExerciseLocationButton : UIButton

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIImageView * locationInfoImageView;
@property (nonatomic, strong) UILabel * locationLabelTextView;

@property (nonatomic, strong) NSString * key;

+ (CGFloat)heightForButtonWithTitle:(NSString*)title;

@end
