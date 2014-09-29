//
//  ShopItem.m
//  StretchMate
//
//  Created by James Eunson on 16/04/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopItem.h"


@implementation ShopItem

@dynamic desc;
@dynamic identifier;
@dynamic name;
@dynamic price;
@dynamic category;
@dynamic image;

- (NSString*)priceString {
    
    double actualPrice = ((double)[[self price] integerValue])/((double)100);
    return [NSString stringWithFormat: @"$%.2lf", actualPrice];
}

@end
