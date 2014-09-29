//
//  TutorialPageViewController.m
//  Exersite
//
//  Created by James Eunson on 7/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "TutorialPageViewController.h"
#import "TutorialViewController.h"

@interface TutorialPageViewController ()

- (void)previousPage;
- (void)nextPage;
- (void)updateInterfaceAfterPageChange;

@end

@implementation TutorialPageViewController

- (id)init {
    self = [super init];
    if(self) {
        
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"TutorialContent" ofType:@"plist"];
        self.contentDictionaries = [NSArray arrayWithContentsOfFile:filePath];
        
        self.selectedContentDictionary = [self.contentDictionaries firstObject];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{}];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    self.pageViewController.view.backgroundColor = [UIColor whiteColor];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.tutorialToolbar = [[TutorialToolbar alloc] init];
    _tutorialToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    _tutorialToolbar.tutorialToolbarDelegate = self;
    [self.view addSubview:_tutorialToolbar];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tutorialToolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tutorialToolbar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tutorialToolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tutorialToolbar)]];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TutorialViewController * pageController = [[TutorialViewController alloc] initWithDictionary:self.contentDictionaries[0]];
    [self.pageViewController setViewControllers:@[pageController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - UIPageViewControllerDataSource Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger contentIndex = [self.contentDictionaries indexOfObject:self.selectedContentDictionary];
    if(contentIndex == 0) return nil;
    
    return [self pageViewControllerForContentIndex:(contentIndex-1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger contentIndex = [self.contentDictionaries indexOfObject:self.selectedContentDictionary];
    if(contentIndex == ([self.contentDictionaries count] -1)) return nil;
    
    return [self pageViewControllerForContentIndex:(contentIndex+1)];
}

- (UIViewController*)pageViewControllerForContentIndex:(NSInteger)contentIndex {
    
    TutorialViewController * contentPageViewController = [[TutorialViewController alloc] initWithDictionary:self.contentDictionaries[contentIndex]];
    return contentPageViewController;
}

#pragma mark - UIPageViewControllerDelegate Methods
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    [self updateInterfaceAfterPageChange];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    TutorialViewController * nextController = [pendingViewControllers firstObject];
    self.selectedContentDictionary = nextController.contentDictionary;
}

#pragma mark - TutorialToolbarDelegate Methods
- (void)tutorialToolbar:(TutorialToolbar *)toolbar didTapNextPageButton:(UIButton *)nextPageButton {
    [self nextPage];
}

- (void)tutorialToolbar:(TutorialToolbar *)toolbar didTapPreviousPageButton:(UIButton *)previousPageButton {
    [self previousPage];
}

#pragma mark - Private Methods
- (void)previousPage {
    
    NSInteger contentIndex = [self.contentDictionaries indexOfObject:self.selectedContentDictionary];
    if(contentIndex == 0) return;
    
    NSDictionary * contentDictionary = self.contentDictionaries[(contentIndex - 1)];
    self.selectedContentDictionary = contentDictionary;
    [self.pageViewController setViewControllers:@[ [self pageViewControllerForContentIndex:(contentIndex - 1)] ] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    [self updateInterfaceAfterPageChange];
}

- (void)nextPage {
    
    NSInteger contentIndex = [self.contentDictionaries indexOfObject:self.selectedContentDictionary];
    if(contentIndex == ([self.contentDictionaries count] - 1)) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSDictionary * contentDictionary = self.contentDictionaries[(contentIndex + 1)];
    self.selectedContentDictionary = contentDictionary;
    [self.pageViewController setViewControllers:@[ [self pageViewControllerForContentIndex:(contentIndex + 1)] ] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self updateInterfaceAfterPageChange];
}

- (void)updateInterfaceAfterPageChange {
    NSInteger contentIndex = [self.contentDictionaries indexOfObject:self.selectedContentDictionary];
    
    self.tutorialToolbar.pageControl.currentPage = contentIndex;
    
    if(contentIndex == ([self.contentDictionaries count] - 1)) {
        self.tutorialToolbar.nextButton.directionTitleLabel.text = @"Done";
    } else {
        self.tutorialToolbar.nextButton.directionTitleLabel.text = @"Next";
    }
    
    if(contentIndex == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tutorialToolbar.previousButton.alpha = 0.f;
        }];
    } else {
        if(self.tutorialToolbar.previousButton.alpha != 1.0f) {
            [UIView animateWithDuration:0.3 animations:^{
                self.tutorialToolbar.previousButton.alpha = 1.f;
            }];
        }
    }
}

@end
