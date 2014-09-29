//
//  Notification.h
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    NotificationTypeUserSignupConfirmed = 1,
    NotificationTypeUserProgramUpdated,
    NotificationTypeUserPatientCompletedExercise,
    NotificationTypeUserProgramAssigned,
    NotificationTypeUserExerciseScheduled,
} NotificationType;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * user;
@property (nonatomic, retain) NSNumber * type;

- (void)markAsRead;
- (NSString*)timeAgoString;

+ (BOOL)notificationExistsWithNotificationIdentifier:(NSNumber*)identifier user:(NSNumber*)user;
+ (Notification*)createNotificationFromNotificationDict:(NSDictionary*)notificationDict;

+ (NSArray*)allNotifications;
+ (NSArray*)allNotificationsFromMyPractitioner;

@end
