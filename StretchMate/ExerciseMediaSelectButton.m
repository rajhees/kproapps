//
//  ExerciseMediaSelectButton.m
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseMediaSelectButton.h"

@interface ExerciseMediaSelectButton()
- (void)wasTappedByUser:(id)sender;
@end

@implementation ExerciseMediaSelectButton

- (id)initWithFrame:(CGRect)frame andType:(ExerciseMediaButtonType)type;
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.type = type;
        
        if(type == ExerciseMediaButtonTypeImages) {
            self.buttonView = [[ExerciseSelectButtonView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) andType:type andInitiallySelected:YES];
        } else {
            self.buttonView = [[ExerciseSelectButtonView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) andType:type andInitiallySelected:NO];
        }
        self.buttonView.userInteractionEnabled = NO;        
        [self addSubview:self.buttonView];
        
        self.shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _shadeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5f];
        _shadeView.layer.cornerRadius = 5.0f;
        _shadeView.hidden = YES;
        _shadeView.userInteractionEnabled = NO;
        [self addSubview:self.shadeView];
        
        [self addTarget:self action:@selector(wasTappedByUser:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)wasTappedByUser:(id)sender {
    
    self.shadeView.hidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.shadeView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.shadeView.hidden = YES;
        self.shadeView.alpha = 1.0f;
    }];
}

@end
