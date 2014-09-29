//
//  ProgramAlarmCell.h
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramAlarmCell : UITableViewCell

@property (nonatomic, strong) UISwitch * switchView;
@property (nonatomic, strong) NSDictionary * alarmDict;

@property (nonatomic, strong) UILabel * generatedTimesLabel;
@property (nonatomic, strong, readonly) NSDateFormatter * scheduledHoursDateFormatter;

+ (CGFloat)heightForCellWithAlarmDict:(NSDictionary*)alarmDict;

@end
