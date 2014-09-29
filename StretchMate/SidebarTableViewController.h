//
//  SidebarTableViewController.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidebarUserCell.h"
#import "LoginViewController.h"

#define kSidebarSections @[ @"exercises", @"programs", @"prescription", @"myexercises", @"shop", @"settings" ]

// Patients have the additional section of "My Practitioner", obviously practitioners don't have this, and "User"-type users
// are not part of the Practitioner-Patient relationship, so don't have this either
#define kPatientAuthorizedSidebarSections @[ @"exercises", @"programs", @"prescription", @"myexercises", @"shop", @"mypractitioner", @"settings" ]
#define kPractitionerAuthorizedSidebarSections @[ @"exercises", @"programs", @"myexercises", @"shop", @"settings" ]
#define kUserAuthorizedSidebarSections @[ @"exercises", @"programs", @"prescription", @"myexercises", @"shop", @"settings" ]

#define kHumanReadableSectionNames @{ @"exercises" : @"Exercises", @"programs" : @"Programs", @"prescription" : @"Prescription", @"myexercises": @"My Exercises", @"shop" : @"Shop", @"mypractitioner" : @"My Practitioner", @"settings": @"Settings" }

@interface SidebarTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, SidebarCellDelegate, UIActionSheetDelegate, LoginControllerDelegate>

@end
