//
//  SMTabBarController.m
//  StretchMate
//
//  Created by James Eunson on 15/04/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "SMTabBarController.h"
#import "ExerciseDetailViewController.h"

@interface SMTabBarController ()

@end

@implementation SMTabBarController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
    }
    return self;
}

- (BOOL)shouldAutorotate;
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
