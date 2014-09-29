//
//  PrescriptionNotLoggedInView.h
//  Exersite
//
//  Created by James Eunson on 27/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrescriptionLoginButton.h"

@protocol PrescriptionNotLoggedInViewDelegate;
@interface PrescriptionNotLoggedInView : UIView

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;

@property (nonatomic, strong) PrescriptionLoginButton * loginButton;

@property (nonatomic, assign) __unsafe_unretained id<PrescriptionNotLoggedInViewDelegate> delegate;

@end

@protocol PrescriptionNotLoggedInViewDelegate <NSObject>
@required
- (void)prescriptionNotLoggedInView:(PrescriptionNotLoggedInView*)view didTapLoginButton:(UIButton*)button;
@end