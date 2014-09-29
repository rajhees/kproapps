//
//  TutorialToolbar.h
//  Exersite
//
//  Created by James Eunson on 7/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"
#import "TutorialDirectionButton.h"

@protocol TutorialToolbarDelegate;
@interface TutorialToolbar : UIToolbar

@property (nonatomic, strong) TutorialDirectionButton * previousButton;
@property (nonatomic, strong) TutorialDirectionButton * nextButton;
@property (nonatomic, strong) StyledPageControl * pageControl;

@property (nonatomic, assign) __unsafe_unretained id<TutorialToolbarDelegate> tutorialToolbarDelegate;

@end

@protocol TutorialToolbarDelegate <NSObject>
@required
- (void)tutorialToolbar:(TutorialToolbar*)toolbar didTapNextPageButton:(UIButton*)nextPageButton;
- (void)tutorialToolbar:(TutorialToolbar*)toolbar didTapPreviousPageButton:(UIButton*)previousPageButton;
@end
