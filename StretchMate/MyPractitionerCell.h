//
//  MyPractitionerCell.h
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginPractitionerCell.h"

@interface MyPractitionerCell : LoginPractitionerCell

@property (nonatomic, strong) NSDictionary * practitionerDict;
@property (nonatomic, strong) UILabel * practiceAddressLabel;

+ (CGFloat)heightWithPractitionerDict:(NSDictionary*)practitionerDict;

@end
