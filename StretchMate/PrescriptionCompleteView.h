//
//  PrescriptionCompleteView.h
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseBigButton.h"

//@protocol PrescriptionCompleteViewDelegate;
@interface PrescriptionCompleteView : UIView

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * bodyMessageLabel;

@property (nonatomic, strong) UIImageView * completeImageView;

//@property (nonatomic, strong) ExerciseBigButton * okBigButton;
//@property (nonatomic, assign) __unsafe_unretained id<PrescriptionCompleteViewDelegate> delegate;

@end

// @protocol PrescriptionCompleteViewDelegate <NSObject>
// @required
// - (void)prescriptionCompleteView:(PrescriptionCompleteView*)view didTapOkButton:(UIButton*)button;
// @end