//
//  ShopOrderCompleteViewController.h
//  Exersite
//
//  Created by James Eunson on 19/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopOrderCompleteScrollView.h"

@interface ShopOrderCompleteViewController : UIViewController <ShopOrderCompleteScrollViewDelegate>

@property (nonatomic, strong) ShopOrderCompleteScrollView * scrollView;

@end
