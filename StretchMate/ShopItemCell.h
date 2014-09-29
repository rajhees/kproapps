//
//  ShopItemCell.h
//  StretchMate
//
//  Created by James Eunson on 4/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgramItemCleanCell.h"

typedef enum {
    ShopItemCellTypeItem,
    ShopItemCellTypeCategory
} ShopItemCellType;

@interface ShopItemCell : ProgramItemCleanCell

@property (nonatomic, assign) ShopItemCellType type;
@property (nonatomic, strong) NSDictionary * itemDict;

+ (CGFloat)heightForShopItem:(NSDictionary*)shopItem;

@end
