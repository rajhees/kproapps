//
//  ExerciseNowCompletingViewController.m
//  StretchMate
//
//  Created by James Eunson on 6/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingViewController.h"
#import "ExerciseBlueButton.h"
#import "ExerciseNowCompletingPageButton.h"
#import "ExerciseDetailViewController.h"
#import "ExerciseNowCompletingStepButtonsView.h"
#import "PractitionerExercise.h"
#import "UIImageView+AFNetworking.h"
#import "RemoteImageViewController.h"
#import "ExerciseNowCompletingStartPauseButton.h"
#import "ProgressHUDHelper.h"

// HealthKit
#import "HealthKitManager.h"

#define kExerciseImagesScrollViewHeight 175.0f

#define kEncourageMessageFirst          @"Well begun is half done."
#define kEncourageMessageSecond         @"Fortune favors the brave."
#define kEncourageMessageThird          @"Reach perfection."
#define kEncourageMessageCompleteThird  @"Excellent effort you completed 3 exercises"

@implementation ExerciseNowCompletingViewController

- (id)initWithMode:(ExerciseNowCompletingViewControllerMode)mode {
    self = [super init];
    if(self) {
        self.mode = mode;
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//    
    NSInteger numberOfExercises = [[NSUserDefaults standardUserDefaults] integerForKey:kExerciseThreeTimesEncourageKey];
    NSLog(@"Exercise View Opened : = %ld", numberOfExercises);
    
    if (numberOfExercises <= 3) {
        numberOfExercises = numberOfExercises + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:numberOfExercises forKey:kExerciseThreeTimesEncourageKey];
        
        if (numberOfExercises > 3) {
            return;
        }
        
        NSString *strMessage;
        switch (numberOfExercises) {
            case 1:
                strMessage = kEncourageMessageFirst;
                break;
            case 2:
                strMessage = kEncourageMessageSecond;
                break;
            case 3:
                strMessage = kEncourageMessageThird;
                break;
                
            default:
                break;
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:strMessage delegate:self cancelButtonTitle:@"Go on" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    self.nowCompletingView = [[ExerciseNowCompletingView alloc] init];
    _nowCompletingView.translatesAutoresizingMaskIntoConstraints = NO;
    _nowCompletingView.selectedExercise = self.selectedExercise;
    _nowCompletingView.delegate = self;
    [self.view addSubview:_nowCompletingView];
    
    if(self.mode == ExerciseNowCompletingViewControllerModeSingle) {
        _nowCompletingView.type = ExerciseNowCompletingViewTypeSingle;
    } else {
        _nowCompletingView.type = ExerciseNowCompletingViewTypeMultiple;
        
        self.completeView = [[PrescriptionNowCompletingCompleteView alloc] init];
        _completeView.translatesAutoresizingMaskIntoConstraints = NO;
        _completeView.hidden = YES;
        [self.view addSubview:_completeView];
    }
    
    NSDictionary * bindings = nil;
    
    if(self.mode == ExerciseNowCompletingViewControllerModeSingle) {
        
        self.nowCompletingToolbar = [[ExerciseNowCompletingToolbar alloc] init];
        _nowCompletingToolbar.type = ExerciseNowCompletingToolbarTypeSingleExercise;
        _nowCompletingToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        _nowCompletingToolbar.selectedExercise = _selectedExercise;
        _nowCompletingToolbar.nowCompletingToolbarDelegate = self;
        [self.view addSubview:_nowCompletingToolbar];
        
        bindings = NSDictionaryOfVariableBindings(_nowCompletingView, _nowCompletingToolbar);
        
    } else {
        bindings = NSDictionaryOfVariableBindings(_nowCompletingView, _completeView);
    }

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nowCompletingView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nowCompletingView]|" options:0 metrics:nil views:bindings]];
    
    if(self.mode == ExerciseNowCompletingViewControllerModeSingle) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nowCompletingToolbar]|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nowCompletingToolbar]|" options:0 metrics:nil views:bindings]];
        
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_completeView]-88-|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_completeView]|" options:0 metrics:nil views:bindings]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    self.title = ((Exercise*)self.selectedExercise).nameBasic;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    self.totalSeconds = [((Exercise*)self.selectedExercise).seconds integerValue];
    self.remainingSeconds = [((Exercise*)self.selectedExercise).seconds integerValue];
    self.paused = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Fixes issue where multiple MPMoviePlayerControllers running concurrently causes players
    // after the first to display a black screen
    if(self.mode == ExerciseNowCompletingViewControllerModeSingle) {
        [self.nowCompletingView.mediaView.playerController prepareToPlay];
        self.nowCompletingView.mediaView.playerController.shouldAutoplay = YES;
    }
}

#pragma mark - Property Override Methods
- (void)setCompleteInPrescriptionExercises:(BOOL)completeInPrescriptionExercises {
    _completeInPrescriptionExercises = completeInPrescriptionExercises;
    
    if(_completeInPrescriptionExercises) {
        self.completeView.hidden = NO;
    } else {
        self.completeView.hidden = YES;
    }
}

#pragma mark - ExerciseNowCompletingViewDelegate Methods
- (void)exerciseNowCompletingView:(ExerciseMediaView*)scrollView didTapImageViewWithParameters:(NSDictionary*)parameters {
//    NSLog(@"exerciseNowCompletingView:didTapImageViewWithParameters:");
    
    if(self.mode == ExerciseNowCompletingViewControllerModeSingle) {
     
        if(![self.nowCompletingToolbar isPaused]) {
            
            self.nowCompletingToolbar.buttonsView.startPauseButton.startPauseState = ExerciseNowCompletingStartPauseButtonModePaused;
            [self.nowCompletingToolbar toggleTimerWithStartStopButton:self.nowCompletingToolbar.buttonsView.startPauseButton];
            [ProgressHUDHelper showConfirmationHUDWithImage:nil withLabelText:@"Timer paused" withDetailsLabelText:@"Press start to continue." withFadeTime:1.0];
        }
        
        Exercise * databaseExercise = (Exercise*)self.selectedExercise;
        NSString * fileName = [[NSBundle mainBundle] pathForResource:[[parameters[kSelectedImagePath] componentsSeparatedByString:@"."] firstObject] ofType:@"jpg"];
        NSURL * imageFileURL = [NSURL fileURLWithPath:fileName];
        
        NSDictionary * destinationControllerParameters = @{ kLocalImageViewImageUrl: imageFileURL, kRemoteImageViewTitle: databaseExercise.nameBasic, kRemoteImageViewSubtitle : databaseExercise.typesString, kShouldShowShareButton: @(NO) };
        RemoteImageViewController * destinationViewController = [[RemoteImageViewController alloc] initWithParameters:destinationControllerParameters];
        destinationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:destinationViewController animated:YES completion:nil];
        
    } else {
        
        // If running within the context of a UIPageViewController, pass the request upwards
        if([self.delegate respondsToSelector:@selector(exerciseNowCompletingViewController:didTapImageViewWithParameters:)]) {
            [self.delegate performSelector:@selector(exerciseNowCompletingViewController:didTapImageViewWithParameters:) withObject:self withObject:parameters];
        }
    }
}

#pragma mark - ExerciseNowCompletingToolbarDelegate Methods
- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapStartPauseButton:(UIButton*)startPauseButton {
    
    // start button click
    
    if(self.nowCompletingView.startFinishHintToolbar) {
        
        if(![[AppConfig sharedConfig] exerciseNowCompletingStartFinishTipActionPerformed]) {
            [[AppConfig sharedConfig] setBool:YES forKey:kExerciseNowCompletingStartFinishTipActionPerformed];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.nowCompletingView.startFinishHintToolbar.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if(finished) {
                [self.nowCompletingView.startFinishHintToolbar removeFromSuperview];
            }
        }];
    }
}

- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapFinishedButton:(UIButton*)finishedButton {
    // I'm Finished button click
    NSInteger numberOfExercCompleted = [[NSUserDefaults standardUserDefaults] integerForKey:kExerciseThreeTimesCompletedKey];
    NSLog(@"Exercise Completed : =%ld", (long)numberOfExercCompleted);
    
    if (numberOfExercCompleted <= 3) {
        numberOfExercCompleted = numberOfExercCompleted + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:numberOfExercCompleted forKey:kExerciseThreeTimesCompletedKey];
        
    }
    if (numberOfExercCompleted == 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:kEncourageMessageCompleteThird delegate:self cancelButtonTitle:@"Go on" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.nowCompletingToolbar) {
        NSNumber *timeRecorded = self.nowCompletingToolbar.recordedTime;
        NSLog(@"Time Recorded in ViewController = %ld", [timeRecorded integerValue]);
        [HealthKitManager saveTimeToHealthKitStore:[timeRecorded intValue]];
        
    }
}
@end
