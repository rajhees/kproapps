//
//  PrescriptionExerciseCell.h
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrescriptionExerciseCell : UITableViewCell

@property (nonatomic, strong) NSDictionary * timeslotDict;

@property (nonatomic, strong) UILabel * completedTimeLabel;

@property (nonatomic, strong) UIView * checkboxView;
@property (nonatomic, strong) UIImageView * tickImageView;

+ (CGFloat)heightForCellWithTimeslotDict:(NSDictionary*)timeslotDict;

@end
