//
//  ExersiteDrawerController.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExersiteDrawerController.h"

@interface ExersiteDrawerController ()
- (void)_loadOtherViewControllers;
@end

@implementation ExersiteDrawerController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if([segue.identifier isEqualToString:@"mm_center"]) {
        
        UINavigationController * navController = (UINavigationController*)segue.destinationViewController;
        self.exercisesNavigationController = navController;
        
        [self _loadOtherViewControllers];
    }
}

- (void)_loadOtherViewControllers {
    
    // Programs
    ProgramsViewController *programsViewController = (ProgramsViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL]
                                                                       instantiateViewControllerWithIdentifier:@"ProgramsViewController"];
    self.programsNavigationController = [[UINavigationController alloc] initWithRootViewController:programsViewController];
    
    // Prescription
    PrescriptionViewController *prescriptionViewController = (PrescriptionViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL]
                                                                               instantiateViewControllerWithIdentifier:@"PrescriptionViewController"];
    self.prescriptionNavigationController = [[UINavigationController alloc] initWithRootViewController:prescriptionViewController];
    
    // Shop
    ShopViewController *shopViewController = (ShopViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL]
                                                                               instantiateViewControllerWithIdentifier:@"ShopViewController"];
    self.shopNavigationController = [[UINavigationController alloc] initWithRootViewController:shopViewController];
    
    // My Practitioner
    MyPractitionerViewController *myPractitionerViewController = (MyPractitionerViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL]
                                                                   instantiateViewControllerWithIdentifier:@"MyPractitionerViewController"];
    self.myPractitionerNavController = [[UINavigationController alloc] initWithRootViewController:myPractitionerViewController];
    
    // My Exercises
    MyExercisesViewController *myExercisesViewController = (MyExercisesViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL]
                                                                                                 instantiateViewControllerWithIdentifier:@"MyExercisesViewController"];
    self.myExercisesNavController = [[UINavigationController alloc] initWithRootViewController:myExercisesViewController];
}

@end
