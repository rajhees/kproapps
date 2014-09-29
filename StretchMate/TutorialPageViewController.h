//
//  TutorialPageViewController.h
//  Exersite
//
//  Created by James Eunson on 7/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialToolbar.h"

@interface TutorialPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, TutorialToolbarDelegate>

@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic, strong) TutorialToolbar * tutorialToolbar;

@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, strong) NSArray * contentDictionaries;
@property (nonatomic, strong) NSDictionary * selectedContentDictionary;

@end
