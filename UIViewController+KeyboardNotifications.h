//
//  UIViewController+KeyboardNotifications.h
//  Exersite
//
//  Created by James Eunson on 9/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KeyboardNotifications)

- (void)registerForKeyboardNotifications;
- (void)unregisterKeyboardNotifications;

@end
