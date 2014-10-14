//
//  ExerciseDetailViewController.m
//  StretchMate
//
//  Created by James Eunson on 24/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseDetailViewController.h"
#import "SavedExercise.h"
#import "ShopDetailViewController.h"
#import "ProgressHUDHelper.h"
#import "ExerciseNowCompletingViewController.h"
#import "ExerciseEquipmentCell.h"
#import "ExerciseDifficultyViewController.h"
#import "AppDelegate.h"
#import "PractitionerExercise.h"
#import "RemoteImageViewController.h"
#import "PortraitNavigationController.h"
#import "ProgramListingViewController.h"
#import "ExercisesListingViewController.h"
#import "EGOCache.h"
#import "ShopViewController.h"

#define kEquipmentCategoriesCacheKey @"exerciseEquipmentCategories"

@interface ExerciseDetailViewController ()

- (void)showActionSheet:(id)sender;
- (void)startExercise:(Exercise*)exercise;
- (void)loadEquipmentCategories;

@property (nonatomic, strong) NSArray * equipmentCategories;

@end

@implementation ExerciseDetailViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.viewingFromPrescriptionProgram = NO;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-bg"]];
        [self.view addSubview:backgroundView];
        [self.view sendSubviewToBack:backgroundView];
        
    } else {
        
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    self.scrollView = [[ExerciseCleanDetailScrollView alloc] init];
    _scrollView.exerciseDetailDelegate = self;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];
    
    //    self.prescribedNotificationToolbar = [[UIToolbar alloc] init];
    //    _prescribedNotificationToolbar.backgroundColor = [UIColor whiteColor];
    //    _prescribedNotificationToolbar.translucent = YES;
    //    [self.view addSubview:_prescribedNotificationToolbar];
    //
    //    self.prescribedLabel = [[UILabel alloc] init];
    //    _prescribedLabel.text = @"You have been prescribed this exercise by your practitioner. Tap for details.";
    //    _prescribedLabel.backgroundColor = [UIColor clearColor];
    //    _prescribedLabel.textColor = RGBCOLOR(142, 142, 149);
    //    _prescribedLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    //    _prescribedLabel.numberOfLines = 0;
    //    _prescribedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //    _prescribedLabel.textAlignment = NSTextAlignmentCenter;
    //    [_prescribedNotificationToolbar addSubview:_prescribedLabel];
    //
    //    self.prescribedNotificationToolbarBorder = [CALayer layer];
    //    _prescribedNotificationToolbarBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
    //    [self.prescribedNotificationToolbar.layer insertSublayer:_prescribedNotificationToolbarBorder atIndex:100];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        self.title = ((Exercise*)self.selectedExercise).nameBasic;
    } else {
        self.title = ((Exercise*)self.selectedExercise).nameBasic;
    }
    
    _scrollView.selectedExercise = self.selectedExercise;
    
    self.actionBarButtonItem.target = self;
    self.actionBarButtonItem.action = @selector(showActionSheet:);
    
    [self loadEquipmentCategories];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.scrollView.mediaView.playerController prepareToPlay];
    self.scrollView.mediaView.playerController.shouldAutoplay = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGSize sizeForPrescribedNotificationLabel = [_prescribedLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _prescribedLabel.frame = CGRectMake(8.0f, 8.0f, self.view.frame.size.width - 16.0f, sizeForPrescribedNotificationLabel.height);
    
    _prescribedNotificationToolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, sizeForPrescribedNotificationLabel.height + 16.0f);
    _prescribedNotificationToolbarBorder.frame = CGRectMake(0, _prescribedNotificationToolbar.frame.size.height - 1.0f, self.view.frame.size.width, 1.0f);
    
    _scrollView.contentInset = UIEdgeInsetsMake(_prescribedNotificationToolbar.frame.size.height, 0, 0, 0);
    
    [self.scrollView updateMediaScrollViewContentOffset];
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    NSLog(@"clickedButtonAtIndex:");
    
    if([[actionSheet buttonTitleAtIndex:buttonIndex] rangeOfString:@"Add"].location != NSNotFound || [[actionSheet buttonTitleAtIndex:buttonIndex] rangeOfString:@"Remove"].location != NSNotFound) {
        
        [_selectedExercise toggleExerciseSaved];
        
        if([_selectedExercise isExerciseSaved]) {
            [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"exercise-starred-confirmation-ios7"] withLabelText:@"Added to My Exercises" withDetailsLabelText:nil withFadeTime:0.75f];
            [_scrollView.starredButton setSelected:YES];
        } else {
            [_scrollView.starredButton setSelected:NO];
        }
        
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] rangeOfString:@"Start"].location != NSNotFound) {
        [self startExercise:self.selectedExercise];
    }
}

#pragma mark - Private Methods
- (void)showActionSheet:(id)sender {
    
    if([_selectedExercise isKindOfClass:[Exercise class]]) {
        
        // This is crap code, I know, I know, I've been working 9 days 12hrs/day straight on this, can't think anymore
        UIActionSheet * sheet = nil;
        if(self.viewingFromPrescriptionProgram) {
            if([_selectedExercise isExerciseSaved]) {
                sheet = [[UIActionSheet alloc] initWithTitle:((Exercise*)self.selectedExercise).nameBasic delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Remove from My Exercises", nil];
            } else {
                sheet = [[UIActionSheet alloc] initWithTitle:((Exercise*)self.selectedExercise).nameBasic delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Add to My Exercises", nil];
            }
        } else {
            if([_selectedExercise isExerciseSaved]) {
                sheet = [[UIActionSheet alloc] initWithTitle:((Exercise*)self.selectedExercise).nameBasic delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Start Exercise", @"Remove from My Exercises", nil];
            } else {
                sheet = [[UIActionSheet alloc] initWithTitle:((Exercise*)self.selectedExercise).nameBasic delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Start Exercise", @"Add to My Exercises", nil];
            }
        }
        
        [sheet showInView:self.view];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"ExerciseNowCompletingSegue"]) {
        
        Exercise * selectedExercise = (Exercise*)sender;
        
        UINavigationController * navController = [segue destinationViewController];
        ExerciseNowCompletingViewController *detailViewController = (ExerciseNowCompletingViewController*)navController.visibleViewController;
        detailViewController.selectedExercise = selectedExercise;
        
    } else if([[segue identifier] isEqualToString:@"ExerciseDifficultySegue"]) {
        
        UINavigationController * navController = [segue destinationViewController];
        ExerciseDifficultyViewController *detailViewController = (ExerciseDifficultyViewController*)navController.visibleViewController;
        detailViewController.selectedExercise = self.selectedExercise;
    }
}

- (void)loadEquipmentCategories {
    
    // Because this could happen pretty often, we're caching it for 1 day at a time, so the dat could be incorrect for 24 hours at most
    // Also, surrounded by try/catch, as this is supposed to be invisible
    @try {
        if([[EGOCache globalCache] hasCacheForKey:kEquipmentCategoriesCacheKey]) {
            
            NSData * equipmentCategoryData = [[EGOCache globalCache] dataForKey:kEquipmentCategoriesCacheKey];
            self.equipmentCategories = (NSArray*) [NSKeyedUnarchiver unarchiveObjectWithData:equipmentCategoryData];
            
        } else {
            
            ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
            [httpClient retrieveShopListing:^(NSDictionary * result) {
                self.equipmentCategories = result[@"categories"];
                
                NSTimeInterval oneDayTimeInterval = (60 * 60 * 24); // 1 day
                NSData * equipmentCategoryData = [NSKeyedArchiver archivedDataWithRootObject:_equipmentCategories];
                [[EGOCache globalCache] setData:equipmentCategoryData forKey:kEquipmentCategoriesCacheKey withTimeoutInterval:oneDayTimeInterval];
            }];
        }
    }
    @catch (NSException *exception) {
//        NSLog(@"Equipment Load Failed");
    }
}

#pragma mark - Property Override Methods
- (void)setEquipmentCategories:(NSArray *)equipmentCategories {
    _equipmentCategories = equipmentCategories;
    
    self.scrollView.equipmentCategories = _equipmentCategories;
}

#pragma mark - ExerciseDetailScrollViewDelegate
- (void)setSelectedExercise:(id)selectedExercise {
    _selectedExercise = selectedExercise;
    
    if(![self.selectedExercise isKindOfClass:[Exercise class]]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)startExercise:(Exercise*)exercise {
    
    ExerciseNowCompletingViewController * nowCompletingViewController = [[ExerciseNowCompletingViewController alloc] init];
    nowCompletingViewController.selectedExercise = exercise;
    
    PortraitNavigationController * navController = [[PortraitNavigationController alloc] initWithRootViewController:nowCompletingViewController];
    nowCompletingViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - ExerciseCleanDetailScrollViewDelegate Methods
- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didTapSubtitleButton:(UIButton*)button {
//    NSLog(@"exerciseCleanDetailScrollView:didTapSubtitleButton:");
    
    ExercisesListingViewController *viewController = (ExercisesListingViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                                                 bundle:NULL] instantiateViewControllerWithIdentifier:@"ExercisesListingViewController"];
    Exercise *exerc = (Exercise*)self.selectedExercise;
    viewController.currentType = [[[exerc types] allObjects] firstObject];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didTapStarredButton:(UIButton*)button {
//    NSLog(@"exerciseCleanDetailScrollView:didTapStarredButton:");
    
    [_selectedExercise toggleExerciseSaved];
    
    if([_selectedExercise isExerciseSaved]) {
        [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"exercise-starred-confirmation-ios7"] withLabelText:@"Added to My Exercises" withDetailsLabelText:nil withFadeTime:0.75f];
    }
}

- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didTapImageViewWithParameters:(NSDictionary*)parameters {
//    NSLog(@"exerciseCleanDetailScrollView:didTapImageView:");
    
    NSDictionary * destinationControllerParameters = nil;
    if([self.selectedExercise isKindOfClass:[Exercise class]]) {
        
        Exercise * databaseExercise = (Exercise*)self.selectedExercise;
        NSString * fileName = [[NSBundle mainBundle] pathForResource:[[parameters[kSelectedImagePath] componentsSeparatedByString:@"."] firstObject] ofType:@"jpg"];
        NSURL * imageFileURL = [NSURL fileURLWithPath:fileName];
        
        destinationControllerParameters = @{ kLocalImageViewImageUrl : imageFileURL, kRemoteImageViewTitle: databaseExercise.nameBasic, kRemoteImageViewSubtitle : databaseExercise.typesString, kShouldShowShareButton: @(NO) };
        
    } else {
        
        PractitionerExercise * practitionerExercise = (PractitionerExercise*)self.selectedExercise;
        destinationControllerParameters = @{ kRemoteImageViewImageUrl : [NSURL URLWithString:parameters[kSelectedImagePath]], kRemoteImageViewTitle: practitionerExercise.nameBasic, kRemoteImageViewSubtitle : practitionerExercise.typesString, kShouldShowShareButton: @(NO) };
    }
    
    RemoteImageViewController * destinationViewController = [[RemoteImageViewController alloc] initWithParameters:destinationControllerParameters];
    destinationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:destinationViewController animated:YES completion:nil];
}

- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didSelectRelatedExercise:(Exercise*)exercise {
    
    ExerciseDetailViewController *viewController = (ExerciseDetailViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                                             bundle:NULL] instantiateViewControllerWithIdentifier:@"ExerciseDetailViewController"];
    viewController.selectedExercise = exercise;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didSelectRelatedProgram:(Program*)program {
    ProgramListingViewController *viewController = (ProgramListingViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                                             bundle:NULL] instantiateViewControllerWithIdentifier:@"ProgramListingViewController"];
    viewController.selectedProgram = program;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView*)scrollView didSelectDifficultyExplanationWithIndexPath:(NSIndexPath *)indexPath {
    //    [self performSegueWithIdentifier:@"ExerciseDifficultySegue" sender:nil];
}

- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView *)scrollView didTapStartExerciseButton:(UIButton *)button {
    [self startExercise:self.selectedExercise];
}

- (void)exerciseCleanDetailScrollView:(ExerciseCleanDetailScrollView *)scrollView didSelectEquipmentCategory:(NSDictionary *)category {
    
    ShopViewController *viewController = (ShopViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL]instantiateViewControllerWithIdentifier:@"ShopViewController"];
    
    viewController.mode = ShopViewControllerModeCategory;
    viewController.selectedCategoryItem = category;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
