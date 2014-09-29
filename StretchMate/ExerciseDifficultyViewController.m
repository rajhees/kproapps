//
//  ExerciseDifficultyViewController.m
//  StretchMate
//
//  Created by James Eunson on 8/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseDifficultyViewController.h"

@interface ExerciseDifficultyViewController ()

@end

@implementation ExerciseDifficultyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
