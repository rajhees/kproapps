//
//  ShopDetailTagView.h
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailTagView : UIView

@property (nonatomic, strong) UILabel * tagLabel;
@property (nonatomic, strong) UIImageView * tagBackgroundView;

- (id)initWithFrame:(CGRect)frame andName:(NSString*)name;
+ (CGFloat)widthForName:(NSString*)name;

@end
