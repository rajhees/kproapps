//
//  ExerciseNowCompletingPageViewController.m
//  StretchMate
//
//  Created by James Eunson on 17/04/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingPageViewController.h"
#import "ExerciseDetailViewController.h"
#import "RemoteImageViewController.h"
#import "ProgressHUDHelper.h"
#import "ExerciseNowCompletingTitleView.h"
#import "ExersiteHTTPClient.h"
#import "ExerciseNowCompletingFinishedViewController.h"
#import "PractitionerExercise.h"

@interface ExerciseNowCompletingPageViewController ()

- (void)previousPage;
- (void)nextPage;
- (void)updateInterfaceAfterPageChange;

- (void)applyCompletionStatusForViewController:(ExerciseNowCompletingViewController*)controller;

@property (nonatomic, strong) ExerciseNowCompletingTitleView * nowCompletingTitleView;

@end

@implementation ExerciseNowCompletingPageViewController

- (id)initWithProgramExercises:(NSArray*)programExercises {
    self = [super init];
    if(self) {
        self.programExercises = programExercises;
        self.pageTurnEnabled = YES;
    }
    return self;
}

// Same as initWithProgramExercises, except includes all prescription metadata attached
// to each exercise, actual programExercises have to be extracted
- (id)initWithPrescriptionProgramExercises:(NSArray*)prescriptionProgramExercises {
    self = [super init];
    if(self) {
        
        self.prescriptionProgramExercises = [prescriptionProgramExercises mutableCopy];
        
        NSMutableArray * exercises = [[NSMutableArray alloc] init];
        for(NSDictionary * exerciseItem in prescriptionProgramExercises) {
            [exercises addObject:exerciseItem[@"exercise"]];
        }
        
        self.programExercises = exercises;
        self.pageTurnEnabled = YES;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{}];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.nowCompletingToolbar = [[ExerciseNowCompletingToolbar alloc] init];
    _nowCompletingToolbar.type = ExerciseNowCompletingToolbarTypeMultipleExercises;
    _nowCompletingToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    _nowCompletingToolbar.nowCompletingToolbarDelegate = self;
    [self.view addSubview:_nowCompletingToolbar];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nowCompletingToolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nowCompletingToolbar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nowCompletingToolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nowCompletingToolbar)]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ExerciseNowCompletingViewController * nowCompletingViewController = [[ExerciseNowCompletingViewController alloc] initWithMode:ExerciseNowCompletingViewControllerModeMultiple];
    nowCompletingViewController.delegate = self;
    
    // If prescribed, we want to skip any completed exercises and show the first incomplete exercise
    if(self.prescriptionProgramExercises) {
        
        int i = 0, startingExerciseIndex = -1;
        for(NSDictionary * timeslotDict in self.prescriptionProgramExercises) {
            
            NSDictionary * timeDict = timeslotDict[@"time"];
            if(![timeDict[@"completed"] boolValue]) {
                startingExerciseIndex = i;
                break;
            }
            i++;
        }
        
        if(startingExerciseIndex != -1) {
            
            id startingExercise = self.programExercises[startingExerciseIndex];
            nowCompletingViewController.selectedExercise = startingExercise;
            self.selectedExercise = startingExercise;
            
        } else {
            
            // Something went wrong, fallback to beginning
            nowCompletingViewController.selectedExercise = [self.programExercises firstObject];
            self.selectedExercise = [self.programExercises firstObject];
        }
        
    } else {
        
        // Otherwise we always start from the beginning
        nowCompletingViewController.selectedExercise = [self.programExercises firstObject];
        self.selectedExercise = [self.programExercises firstObject];
    }
    
    self.nowCompletingToolbar.selectedExercise = _selectedExercise;
    self.nowCompletingToolbar.programExercises = [NSArray arrayWithArray:_programExercises];
    
    self.nowCompletingTitleView = [[ExerciseNowCompletingTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    _nowCompletingTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _nowCompletingTitleView.titleLabel.text = [_selectedExercise nameBasic];
    _nowCompletingTitleView.pageLabel.text = [NSString stringWithFormat:@"%d of %d", ([self.programExercises indexOfObject:_selectedExercise] + 1), [self.programExercises count]];
    self.navigationItem.titleView = _nowCompletingTitleView;
    
    [self.pageViewController setViewControllers:@[nowCompletingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self updateInterfaceAfterPageChange];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UIPageViewControllerDelegate Methods
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
//    NSLog(@"pageViewController: willTransitionToViewControllers:");
    
    ExerciseNowCompletingViewController * nextController = [pendingViewControllers firstObject];
    self.selectedExercise = nextController.selectedExercise;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    [self updateInterfaceAfterPageChange];
}

#pragma mark - UIPageViewControllerDataSource Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if(![self isPageTurnEnabled]) {
        return nil;
    }
    
    NSInteger contentIndex = [self.programExercises indexOfObject:self.selectedExercise];
    if(contentIndex == 0) return nil;
    
    return [self pageViewControllerForContentIndex:(contentIndex-1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if(![self isPageTurnEnabled]) {
        return nil;
    }
    
    NSInteger contentIndex = [self.programExercises indexOfObject:self.selectedExercise];
    if(contentIndex == ([self.programExercises count] -1)) return nil;
    
    return [self pageViewControllerForContentIndex:(contentIndex+1)];
}

- (ExerciseNowCompletingViewController*)pageViewControllerForContentIndex:(NSInteger)contentIndex {
    
    Exercise * nextExercise = self.programExercises[contentIndex];
    
    ExerciseNowCompletingViewController * contentPageViewController = [[ExerciseNowCompletingViewController alloc] initWithMode:ExerciseNowCompletingViewControllerModeMultiple];
    contentPageViewController.selectedExercise = nextExercise;
    
    return contentPageViewController;
}

#pragma mark - ExerciseNowCompletingToolbarDelegate Methods
- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapPreviousButton:(UIButton*)previousButton {
//    NSLog(@"exerciseNowCompletingToolbar:didTapPreviousButton: previousButton tapped");
    
    [self previousPage];
}

- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapNextButton:(UIButton*)nextButton {
//    NSLog(@"exerciseNowCompletingToolbar:didTapNextButton: nextButton tapped");
    
    [self nextPage];
}

- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapStartPauseButton:(UIButton*)startPauseButton {
//    NSLog(@"exerciseNowCompletingToolbar:didTapStartPauseButton:");
    
    ExerciseNowCompletingViewController * currentViewController = [self.pageViewController.viewControllers firstObject];
    
    if(currentViewController.nowCompletingView.startFinishHintToolbar) {

        if(![[AppConfig sharedConfig] exerciseNowCompletingStartFinishTipActionPerformed]) {
            [[AppConfig sharedConfig] setBool:YES forKey:kExerciseNowCompletingStartFinishTipActionPerformed];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            currentViewController.nowCompletingView.startFinishHintToolbar.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if(finished) {
                [currentViewController.nowCompletingView.startFinishHintToolbar removeFromSuperview];
            }
        }];
    }
    
    // Button is in post-tap state now, toggled
    if(((ExerciseNowCompletingStartPauseButton*)startPauseButton).startPauseState == ExerciseNowCompletingStartPauseButtonModePlaying) {
        
        self.pageTurnEnabled = NO;
        
        [self.nowCompletingToolbar.buttonsView.previousButton setDirectionButtonEnabled:NO];
        [self.nowCompletingToolbar.buttonsView.nextButton setDirectionButtonEnabled:NO];
        
    } else {
        
        self.pageTurnEnabled = YES;
        
        ExerciseNowCompletingViewController * currentViewController = [self pageViewControllerForContentIndex:[self.programExercises indexOfObject:self.selectedExercise]];
        [self.pageViewController setViewControllers:@[currentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
//        [self updateInterfaceAfterPageChange]; // Reset page turn to whatever it should be at this point
        [self.nowCompletingToolbar updateInterfaceAfterPageChange];        
    }
    
//    ExerciseNowCompletingViewController * currentViewController = [self pageViewControllerForContentIndex:[_programExercises indexOfObject:self.selectedExercise]];
//    [currentViewController toggleTimerWithStartStopButton:((ExerciseNowCompletingStartPauseButton*)startPauseButton)];
}

- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapFinishedButton:(UIButton *)finishedButton {
    
    if(self.prescriptionProgramExercises) {
        
        NSInteger indexOfCurrentExercise = [self.programExercises indexOfObject:self.selectedExercise];
        __block NSMutableDictionary * timeslotDict = [self.prescriptionProgramExercises[indexOfCurrentExercise] mutableCopy];
        __block NSMutableDictionary * timeDict = [timeslotDict[@"time"] mutableCopy];
        
        MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:@"Marking as Completed..." withDetailsLabelText:nil];
        
        ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
        [httpClient updateCompletionStatusForConcreteExerciseTimeWithParams:@{ @"id": timeDict[@"id"], @"completed": @(YES) } completion:^(NSDictionary *result) {
            
            [loadingView hide:YES];
            
            // Update local state
            timeDict[@"completed"] = @(YES);
            timeslotDict[@"time"] = timeDict;
            [self.prescriptionProgramExercises replaceObjectAtIndex:indexOfCurrentExercise withObject:timeslotDict];
            
            BOOL allCompleted = YES;
            for(NSDictionary * timeslot in self.prescriptionProgramExercises) {
                NSDictionary * timeForTimeslot = timeslot[@"time"];
                
                if(![timeForTimeslot[@"completed"] boolValue]) {
                    allCompleted = NO;
                    break;
                }
            }
            
            if(allCompleted) {
                
                ExerciseNowCompletingFinishedViewController * controller = [[ExerciseNowCompletingFinishedViewController alloc] init];
                
                self.navigationItem.titleView = nil;
                self.navigationItem.title = @"Exercises Finished";
                
                self.nowCompletingToolbar.hidden = YES;
                [self.pageViewController setViewControllers:@[ controller ] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                self.pageTurnEnabled = NO;
                
            } else {
                
                [self nextPage];
            }
            
//            NSLog(@"updateCompletionStatusForConcreteExerciseTimeWithParams completion fired");
            [ProgressHUDHelper showConfirmationHUDWithImage:Nil withLabelText:@"Exercise Completed" withDetailsLabelText:nil withFadeTime:1.0f];
        }];
        
    } else {
        
        [ProgressHUDHelper showConfirmationHUDWithImage:Nil withLabelText:@"Exercise Completed" withDetailsLabelText:nil withFadeTime:1.0f];
        if([self.programExercises indexOfObject:_selectedExercise] != ([self.programExercises count] - 1)) {
            [self nextPage];
        }
    }
}

#pragma mark - ExerciseNowCompletingPageDelegate Methods
- (void)exerciseNowCompletingViewController:(ExerciseNowCompletingViewController*)controller didTapImageViewWithParameters:(NSDictionary*)parameters {
    
    if(![self.nowCompletingToolbar isPaused]) {
        
        self.nowCompletingToolbar.buttonsView.startPauseButton.startPauseState = ExerciseNowCompletingStartPauseButtonModePaused;
        [self.nowCompletingToolbar toggleTimerWithStartStopButton:self.nowCompletingToolbar.buttonsView.startPauseButton];
        [ProgressHUDHelper showConfirmationHUDWithImage:nil withLabelText:@"Timer paused" withDetailsLabelText:@"Press start to continue." withFadeTime:1.0];
    }
    
    NSDictionary * destinationControllerParameters = nil;
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        
        Exercise * databaseExercise = (Exercise*)self.selectedExercise;
        NSString * fileName = [[NSBundle mainBundle] pathForResource:[[parameters[kSelectedImagePath] componentsSeparatedByString:@"."] firstObject] ofType:@"jpg"];
        NSURL * imageFileURL = [NSURL fileURLWithPath:fileName];
        
        destinationControllerParameters = @{ kLocalImageViewImageUrl: imageFileURL, kRemoteImageViewTitle: databaseExercise.nameBasic, kRemoteImageViewSubtitle : databaseExercise.typesString, kShouldShowShareButton: @(NO) };
        
    } else {
        
        PractitionerExercise * practitionerExercise = (PractitionerExercise*)self.selectedExercise;
        if(!practitionerExercise.image) {
            return;
        }
        
        destinationControllerParameters = @{ kRemoteImageViewImageUrl: [NSURL URLWithString:practitionerExercise.image], kRemoteImageViewTitle: practitionerExercise.nameBasic, kRemoteImageViewSubtitle : practitionerExercise.typesString, kShouldShowShareButton: @(NO) };
    }
    
    RemoteImageViewController * destinationViewController = [[RemoteImageViewController alloc] initWithParameters:destinationControllerParameters];
    destinationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:destinationViewController animated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)updateInterfaceAfterPageChange {
    
    NSInteger indexOfCurrentlyVisiblePage = [self.programExercises indexOfObject:_selectedExercise];
    NSInteger numberOfProgramExercises = [self.programExercises count];
    
    _nowCompletingToolbar.selectedExercise = self.selectedExercise;
    _nowCompletingToolbar.programExercises = self.programExercises;
    
    _nowCompletingTitleView.titleLabel.text = _selectedExercise.nameBasic;
    _nowCompletingTitleView.pageLabel.text = [NSString stringWithFormat:@"%d of %d", (indexOfCurrentlyVisiblePage + 1), numberOfProgramExercises];
    
    [self.nowCompletingToolbar updateInterfaceAfterPageChange];
    [self.nowCompletingToolbar resetFinishedButton];
    
    [self applyCompletionStatusForViewController:[self.pageViewController.viewControllers firstObject]];
    
    ExerciseNowCompletingViewController * controller = [self.pageViewController.viewControllers firstObject];
    MPMoviePlayerController * moviePlayerController = controller.nowCompletingView.mediaView.playerController;
                                                       
    [controller.nowCompletingView.mediaView.playerController prepareToPlay];
    [controller.nowCompletingView.mediaView.playerController play];
}

- (void)previousPage {
    
    NSInteger contentIndex = [self.programExercises indexOfObject:self.selectedExercise];
    if(contentIndex == 0) return;
    
    Exercise * prevExercise = self.programExercises[(contentIndex - 1)];
    self.selectedExercise = prevExercise;
    [self.pageViewController setViewControllers:@[ [self pageViewControllerForContentIndex:(contentIndex - 1)] ] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    [self updateInterfaceAfterPageChange];
}

- (void)nextPage {
    
    NSInteger contentIndex = [self.programExercises indexOfObject:self.selectedExercise];
    
    // Behaves differently in prescription mode
    if(self.prescriptionProgramExercises) {
        
        if(contentIndex == ([self.programExercises count] -1)) {
            
            // Find next incomplete item
            int targetContentIndex = 0;
            for(NSDictionary * timeslot in self.prescriptionProgramExercises) {
                NSDictionary * timeForTimeslot = timeslot[@"time"];
                
                if(![timeForTimeslot[@"completed"] boolValue]) {
                    contentIndex = targetContentIndex;
                    break;
                }
                targetContentIndex++;
            }
            
        } else {
            contentIndex = (contentIndex + 1);
        }
        
        Exercise * nextExercise = self.programExercises[contentIndex];
        self.selectedExercise = nextExercise;
        [self.pageViewController setViewControllers:@[ [self pageViewControllerForContentIndex:contentIndex] ] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
    } else {
        
        if(contentIndex == ([self.programExercises count] -1)) return;
        
        Exercise * nextExercise = self.programExercises[(contentIndex + 1)];
        self.selectedExercise = nextExercise;
        [self.pageViewController setViewControllers:@[ [self pageViewControllerForContentIndex:(contentIndex + 1)] ] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    [self updateInterfaceAfterPageChange];
}

- (void)applyCompletionStatusForViewController:(ExerciseNowCompletingViewController *)controller {
    
    if(self.prescriptionProgramExercises) {
        
        NSInteger contentIndex = [self.programExercises indexOfObject:self.selectedExercise];
        NSDictionary * timeslotDict = self.prescriptionProgramExercises[contentIndex];
        NSDictionary * timeDict = timeslotDict[@"time"];
        
        if([timeDict[@"completed"] boolValue]) {
            controller.completeInPrescriptionExercises = YES;
            self.nowCompletingToolbar.buttonsView.startPauseButton.startPauseEnabled = NO;
        } else {
            controller.completeInPrescriptionExercises = NO;
            self.nowCompletingToolbar.buttonsView.startPauseButton.startPauseEnabled = YES;
        }
    }
}

@end
