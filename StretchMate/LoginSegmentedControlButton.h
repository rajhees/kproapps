//
//  LoginSegmentedControlButton.h
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LoginSegmentedControlButtonLastTouchNothing,
    LoginSegmentedControlButtonLastTouchPrevious,
    LoginSegmentedControlButtonLastTouchNext
} LoginSegmentedControlButtonLastTouch;

@interface LoginSegmentedControlButton : UISegmentedControl

@property (nonatomic, assign) LoginSegmentedControlButtonLastTouch lastTouch;

@end
