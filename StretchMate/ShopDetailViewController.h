//
//  ShopDetailViewController.h
//  StretchMate
//
//  Created by James Eunson on 4/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopDetailScrollView.h"
#import "ShopItem.h"

typedef enum {
    ShopDetailModeNormal,
    ShopDetailModeModal
} ShopDetailMode;

@interface ShopDetailViewController : UIViewController <ShopDetailScrollViewDelegate>

@property (nonatomic, strong) NSDictionary * selectedItem;
@property (nonatomic, strong) ShopDetailScrollView * scrollView;
@property (nonatomic, assign) ShopDetailMode mode;

- (id)initWithMode:(ShopDetailMode)mode;

@end
