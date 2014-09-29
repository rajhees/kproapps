//
//  TutorialDirectionButton.h
//  Exersite
//
//  Created by James Eunson on 7/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TutorialDirectionButtonTypePrev,
    TutorialDirectionButtonTypeNext
} TutorialDirectionButtonType;

@interface TutorialDirectionButton : UIButton

@property (nonatomic, strong) UILabel * directionTitleLabel;
@property (nonatomic, assign) TutorialDirectionButtonType type;

- (id)initWithType:(TutorialDirectionButtonType)type;

@end
