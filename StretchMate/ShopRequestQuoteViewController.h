//
//  ShopRequestQuoteViewController.h
//  Exersite
//
//  Created by James Eunson on 21/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopRequestQuoteScrollView.h"

@interface ShopRequestQuoteViewController : UIViewController <ShopRequestQuoteScrollViewDelegate>

@property (nonatomic, strong) ShopRequestQuoteScrollView * scrollView;

@end
