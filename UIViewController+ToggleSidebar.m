//
//  UIViewController+ToggleSidebar.m
//  Exersite
//
//  Created by James Eunson on 27/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "UIViewController+ToggleSidebar.h"
#import "AppDelegate.h"

@implementation UIViewController (ToggleSidebar)

- (void)didToggleSidebar:(id)sender {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    MMDrawerController * drawerController = (MMDrawerController*)delegate.window.rootViewController;
    [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
