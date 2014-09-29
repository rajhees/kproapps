//
//  ProgramSectionHeader.h
//  Exersite
//
//  Created by James Eunson on 19/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kProgramSectionHeaderHeight 23.0f

@interface ProgramSectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UIView * sectionBackgroundView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) CALayer * bottomBorderLayer;

@property (nonatomic, strong) UILabel * actionLabel;

@end
