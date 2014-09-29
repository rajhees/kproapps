//
//  ProgramAlarmCell.m
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramAlarmCell.h"

#define kGeneratedTimesTemplate @"Scheduled alarms: %@"

static NSDateFormatter * scheduledHoursDateFormatter = nil;

@interface ProgramAlarmCell ()

+ (NSString*)scheduledAlarmsStringForAlarmDict:(NSDictionary*)alarmDict;

@end

@implementation ProgramAlarmCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.switchView = [[UISwitch alloc] init];
        _switchView.userInteractionEnabled = NO;
        
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.detailTextLabel.textColor = [UIColor grayColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        
        self.generatedTimesLabel = [[UILabel alloc] init];
        _generatedTimesLabel.font = [UIFont systemFontOfSize:13.0f];
        _generatedTimesLabel.textColor = kTintColour;
        _generatedTimesLabel.backgroundColor = [UIColor clearColor];
        _generatedTimesLabel.numberOfLines = 0;
        _generatedTimesLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _generatedTimesLabel.hidden = YES;
        [self.contentView addSubview:_generatedTimesLabel];
        
        if(!scheduledHoursDateFormatter) {
            scheduledHoursDateFormatter = [[NSDateFormatter alloc] init];
            [scheduledHoursDateFormatter setDateFormat:@"hh:mm a"];
            NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [scheduledHoursDateFormatter setLocale:locale];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat widthForSwitch = _switchView.intrinsicContentSize.width;
    
    CGSize sizeForTextLabel = [self.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 24.0f - widthForSwitch, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.textLabel.frame = CGRectMake(8.0f, 8.0f, self.frame.size.width - 24.0f - widthForSwitch, sizeForTextLabel.height);
    
    CGSize sizeForDetailTextLabel = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 24.0f - widthForSwitch, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.detailTextLabel.frame = CGRectMake(8.0f, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 4.0f, self.frame.size.width - 24.0f - widthForSwitch, sizeForDetailTextLabel.height);
    
    if(!self.generatedTimesLabel.hidden) {
        CGSize sizeForGeneratedTimesLabel = [self.generatedTimesLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 24.0f - widthForSwitch, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        self.generatedTimesLabel.frame = CGRectMake(8.0f, self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height + 4.0f, self.frame.size.width - 24.0f - widthForSwitch, sizeForGeneratedTimesLabel.height);
    }
}

+ (CGFloat)heightForCellWithAlarmDict:(NSDictionary*)alarmDict {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat widthForSwitch = [[UISwitch alloc] init].intrinsicContentSize.width;
    
    CGSize sizeForTextLabel = [alarmDict[@"title"] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 24.0f - widthForSwitch, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize sizeForDetailTextLabel = [alarmDict[@"description"] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 24.0f - widthForSwitch, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary * alarms = [[AppConfig sharedConfig] programAlarmsEnabled];
    NSString * identifierString = alarmDict[@"id"];
    
    if([[alarms allKeys] containsObject:identifierString]) {
        
        NSString * generatedTimesString = [self scheduledAlarmsStringForAlarmDict:alarmDict];
        CGSize sizeForGeneratedTimesLabel = [generatedTimesString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 24.0f - widthForSwitch, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        
        return 8.0f + ceilf(sizeForTextLabel.height) + 4.0f + ceilf(sizeForDetailTextLabel.height) + 4.0f + ceilf(sizeForGeneratedTimesLabel.height) + 8.0f;
        
    } else {
        
        return 8.0f + ceilf(sizeForTextLabel.height) + 4.0f + ceilf(sizeForDetailTextLabel.height) + 8.0f;
    }
}

#pragma mark - Private Methods
+ (NSString*)scheduledAlarmsStringForAlarmDict:(NSDictionary*)alarmDict {
    
    if(!scheduledHoursDateFormatter) {
        scheduledHoursDateFormatter = [[NSDateFormatter alloc] init];
        [scheduledHoursDateFormatter setDateFormat:@"hh:mm a"];
        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [scheduledHoursDateFormatter setLocale:locale];
    }
    
    // Retrieve scheduled notifications for this alarm
    NSMutableArray * scheduledDates = [[NSMutableArray alloc] init];
    NSArray * scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for(UILocalNotification * notification in scheduledNotifications) {
        
        NSDictionary * userInfo = [notification userInfo];        
        
        NSInteger userInfoIdentifier = [userInfo[@"id"] integerValue];
        NSInteger alarmDictIdentifier = [alarmDict[@"id"] integerValue];
        
        if(userInfoIdentifier == alarmDictIdentifier) {
            [scheduledDates addObject:notification.fireDate];
        }
    }
    
    if([scheduledDates count] == 0) {
        return [NSString stringWithFormat:kGeneratedTimesTemplate, @"None"];
        
    } else {
        NSMutableArray * scheduledDateStrings = [[NSMutableArray alloc] init];
        for(NSDate * scheduledDate in scheduledDates) {
            [scheduledDateStrings addObject:[scheduledHoursDateFormatter stringFromDate:scheduledDate]];
        }
        return [NSString stringWithFormat:kGeneratedTimesTemplate, [scheduledDateStrings componentsJoinedByString:@", "]];
    }
}

#pragma mark - Property Override Methods
- (void)setAlarmDict:(NSDictionary *)alarmDict {
    _alarmDict = alarmDict;
    
    self.textLabel.text = alarmDict[@"title"];
    self.detailTextLabel.text = alarmDict[@"description"];
    
    self.accessoryView = _switchView;
    
    NSDictionary * alarms = [[AppConfig sharedConfig] programAlarmsEnabled];
    NSString * identifierString = alarmDict[@"id"];
    
    if([[alarms allKeys] containsObject:identifierString]) {
        
        [_switchView setOn:YES];
        self.generatedTimesLabel.hidden = NO;
        self.generatedTimesLabel.text = [[self class] scheduledAlarmsStringForAlarmDict:alarmDict];
        
    } else {
        
        [_switchView setOn:NO];
        self.generatedTimesLabel.hidden = YES;
    }
    
    [self setNeedsLayout];
}

@end
