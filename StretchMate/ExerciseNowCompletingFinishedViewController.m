//
//  ExerciseNowCompletingFinishedViewController.m
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingFinishedViewController.h"

@interface ExerciseNowCompletingFinishedViewController ()

@end

@implementation ExerciseNowCompletingFinishedViewController

- (void)loadView {
    [super loadView];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.completeView = [[PrescriptionCompleteView alloc] init];
    _completeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_completeView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_completeView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_completeView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_completeView]|" options:0 metrics:nil views:bindings]];
}

@end
