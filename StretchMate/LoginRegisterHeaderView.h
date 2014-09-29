//
//  LoginRegisterHeaderView.h
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginRegisterHeaderView : UIView

@property (nonatomic, strong) UILabel * headingLabel;
@property (nonatomic, strong) UILabel * subHeadingLabel;

+ (CGFloat)heightForHeaderViewWithTitle:(NSString*)title andSubtitle:(NSString*)subtitle;

@end
