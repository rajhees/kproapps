//
//  Notification.m
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "Notification.h"
#import "NSDate+TimeAgo.h"
#import "AppDelegate.h"
#import "ExersiteSession.h"

static NSDateFormatter * dateFormatter = nil;

@interface Notification()
+ (NSManagedObjectContext*)userContext;
+ (Notification*)notificationForIdentifier:(NSNumber*)identifier user:(NSNumber*)user;
@end

@implementation Notification

@dynamic identifier;
@dynamic message;
@dynamic read;
@dynamic time;
@dynamic user;
@dynamic type;

- (NSString*)timeAgoString {
    
    NSString * timeAgoString = [self.time timeAgo];
    timeAgoString = [NSString stringWithFormat:@"%@%@", [[timeAgoString substringWithRange:NSMakeRange(0, 1)] lowercaseString], [timeAgoString substringFromIndex:1]];
    
    return timeAgoString;
}

- (void)markAsRead {
    
    self.read = [NSNumber numberWithBool:YES];
    
    NSError * error = nil;
    [[[self class] userContext] save:&error];
}

// For current user only
+ (NSArray*)allNotifications {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Notification" inManagedObjectContext:[[self class] userContext]]];
    
    NSPredicate * userPredicate = [NSPredicate predicateWithFormat:@"user == %@", [[ExersiteSession currentSession] userIdentifier]];
    [fetchRequest setPredicate: userPredicate];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    
    NSError * error = nil;
    NSArray * notifications = [[[self class] userContext] executeFetchRequest:fetchRequest error:&error];
    
    return notifications;
}

+ (NSArray*)allNotificationsFromMyPractitioner {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Notification" inManagedObjectContext:[[self class] userContext]]];
    
    NSPredicate * userPredicate = [NSPredicate predicateWithFormat:@"user == %@", [[ExersiteSession currentSession] userIdentifier]];
    NSPredicate * typePredicate = [NSPredicate predicateWithFormat:@"type == %@ OR type == %@", @(NotificationTypeUserProgramUpdated), @(NotificationTypeUserProgramAssigned)];
    NSPredicate * compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ userPredicate, typePredicate ]];
    
    [fetchRequest setPredicate: compoundPredicate];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    
    [fetchRequest setFetchLimit:20];

    NSError * error = nil;
    NSArray * notifications = [[[self class] userContext] executeFetchRequest:fetchRequest error:&error];
    
    return notifications;
}

+ (Notification*)createNotificationFromNotificationDict:(NSDictionary *)notificationDict {
    
    // Don't recreate a notification that already exists
    if([[self class] notificationExistsWithNotificationIdentifier:@([notificationDict[@"id"] intValue]) user:@([notificationDict[@"user"] intValue])]) {
        return [[self class] notificationForIdentifier:@([notificationDict[@"id"] intValue]) user:@([notificationDict[@"user"] intValue])];
    }
    
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
    }
    
    Notification * item = (Notification*)[NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:[[self class] userContext]];
    item.identifier = @([notificationDict[@"id"] intValue]);
    item.message = notificationDict[@"message"];
    item.user = @([notificationDict[@"user"] intValue]);
    item.type = @([notificationDict[@"type"] intValue]);
    item.read = [NSNumber numberWithBool:[notificationDict[@"read"] isEqualToString:@"true"]];
    item.time = [dateFormatter dateFromString:notificationDict[@"time"]];
    
    NSError * error = nil;
    BOOL success = [[[self class] userContext] save:&error];
    
    if(success) {
        return item;
    } else {
        return nil;
    }
}

+ (BOOL)notificationExistsWithNotificationIdentifier:(NSNumber*)identifier user:(NSNumber *)user {
    return ([[self class] notificationForIdentifier:identifier user:user] != nil);
}

#pragma mark - Private Methods
+ (NSManagedObjectContext*)userContext {
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [delegate userManagedObjectContext];
}

+ (Notification*)notificationForIdentifier:(NSNumber*)identifier user:(NSNumber *)user {
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Notification" inManagedObjectContext:[[self class] userContext]]];
    NSPredicate * identifierPredicate = [NSPredicate predicateWithFormat:@"identifier == %@ AND user == %@", identifier, user];
    [fetchRequest setPredicate: identifierPredicate];
    
    NSError * error = nil;
    NSArray * notifications = [[[self class] userContext] executeFetchRequest:fetchRequest error:&error];
    
    return [notifications firstObject];
}

@end
