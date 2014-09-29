//
//  ProgramItemCell.h
//  StretchMate
//
//  Created by James Eunson on 16/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kProgramCellHeight 130
#define kProgramCellWidth 142
#define kProgramCellMarginBottom 10.0f
#define kProgramInsetSize 10.0f
#define kProgramLabelTopMargin 4.0f
#define kProgramGutterHeight 23.0f
#define kProgramGutterBottomMargin 8.0f

@interface ProgramItemCell : UICollectionViewCell

@property (nonatomic, strong) UIView * shadeView;
@property (nonatomic, strong) UIView * itemHighlightView;
@property (nonatomic, strong) UIImageView * itemImageView;
@property (nonatomic, strong) UILabel * itemLabel;
@property (nonatomic, strong) UILabel * itemGutterLabel;
@property (nonatomic, strong) NSString * itemTitleString;
@property (nonatomic, strong) UIImageView * topCapImageView;

+ (CGSize)sizeForOverviewImageWithTitleString:(NSString*)itemTitleString;
+ (CGFloat)verticalOffsetForOverviewImageWithTitleString:(NSString*)itemTitleString;

@end
