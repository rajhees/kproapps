//
//  LoginSegmentedControlButton.m
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginSegmentedControlButton.h"

@implementation LoginSegmentedControlButton

- (id)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if(self) {
        self.lastTouch = LoginSegmentedControlButtonLastTouchNothing;
        self.momentary = YES;
    }
    return self;
}

// This function exists so we can pick up touches on disabled items and prevent
// anything from happening at the controller level
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    if(location.x > (self.frame.size.width / 2)) { // Next
        self.lastTouch = LoginSegmentedControlButtonLastTouchNext;
    } else { // Previous
        self.lastTouch = LoginSegmentedControlButtonLastTouchPrevious;
    }
    
    [super touchesEnded:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
