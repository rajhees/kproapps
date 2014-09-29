//
//  ExerciseNowCompletingPageButton.h
//  StretchMate
//
//  Created by James Eunson on 12/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PageButtonDirectionPrevious,
    PageButtonDirectionNext
} PageButtonDirection;

@interface ExerciseNowCompletingPageButton : UIButton

@property (nonatomic, strong) UILabel * directionLabel;
@property (nonatomic, strong) UIView * highlightView;
@property (nonatomic, assign) PageButtonDirection direction;

- (id)initWithFrame:(CGRect)frame direction:(PageButtonDirection)direction;

@end
