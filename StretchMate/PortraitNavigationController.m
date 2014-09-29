//
//  PortraitNavigationController.m
//  Exersite
//
//  Created by James Eunson on 2/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PortraitNavigationController.h"

@interface PortraitNavigationController ()

@end

@implementation PortraitNavigationController

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
