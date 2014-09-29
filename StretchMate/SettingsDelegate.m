//
//  SettingsDelegate.m
//  Exersite
//
//  Created by James Eunson on 1/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "SettingsDelegate.h"
#import "TutorialPageViewController.h"

@implementation SettingsDelegate

- (void)settingsViewController:(id)sender buttonTappedForKey:(NSString*)key {
    
    if([key isEqualToString:@"resetAppPushRegistration"]) {
        
        [[AppConfig sharedConfig] setBool:NO forKey:kPushNotificationDeviceTokenRecorded];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Push Registration" message:@"Push registration reset." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    } else if([key isEqualToString:@"resetTimeZoneRegistration"]) {
        
        [[AppConfig sharedConfig] setBool:NO forKey:kUserTimeZoneRecorded];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Time Zone Registration" message:@"Time zone registration reset." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    } else if([key isEqualToString:@"resetTutorialShown"]) {
        
        [[AppConfig sharedConfig] setBool:NO forKey:kTutorialShown];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Tutorial Shown" message:@"Tutorial shown reset." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    } else if([key isEqualToString:@"clearAllReminders"]) {
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[AppConfig sharedConfig] setObject:@{} forKey:kProgramAlarmsEnabled];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear All Reminders" message:@"Reminders cleared." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    } else if([key isEqualToString:@"showTutorial"]) {
        
        TutorialPageViewController * controller = [[TutorialPageViewController alloc] init];
        IASKAppSettingsViewController * settingsViewController = (IASKAppSettingsViewController*)sender;
        [settingsViewController presentViewController:controller animated:YES completion:nil];
    }
}

@end
