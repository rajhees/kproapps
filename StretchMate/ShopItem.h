//
//  ShopItem.h
//  StretchMate
//
//  Created by James Eunson on 16/04/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShopItem : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * image;

- (NSString*)priceString;

@end
