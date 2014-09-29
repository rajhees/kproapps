//
//  ExersiteDrawerController.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "MMDrawerController.h"

#import "ExercisesViewController.h"
#import "ProgramsViewController.h"
#import "PrescriptionViewController.h"
#import "ShopViewController.h"
#import "MyPractitionerViewController.h"
#import "MyExercisesViewController.h"

@interface ExersiteDrawerController : MMDrawerController

@property (nonatomic, strong) UINavigationController * exercisesNavigationController;
@property (nonatomic, strong) UINavigationController * programsNavigationController;
@property (nonatomic, strong) UINavigationController * prescriptionNavigationController;
@property (nonatomic, strong) UINavigationController * shopNavigationController;
@property (nonatomic, strong) UINavigationController * myPractitionerNavController;
@property (nonatomic, strong) UINavigationController * myExercisesNavController;

@end
