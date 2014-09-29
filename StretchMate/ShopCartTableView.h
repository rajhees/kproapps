//
//  ShopCartTableView.h
//  Exersite
//
//  Created by James Eunson on 6/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ShopCartTableViewTypeNormal,
    ShopCartTableViewTypeRequestQuote,
    ShopCartTableViewTypeOrder
} ShopCartTableViewType;

@protocol ShopCartTableViewDelegate;
@interface ShopCartTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) ShopCartTableViewType type;
@property (nonatomic, assign) __unsafe_unretained id<ShopCartTableViewDelegate> shopCartTableDelegate;

// Optional properties that support the checkout process, when the user is purchasing
// from outside Australia (designated international)
@property (nonatomic, strong) NSString * internationalShippingCountry;
@property (nonatomic, strong) NSNumber * internationalShippingAmount;

@property (nonatomic, strong) NSDictionary * order;

- (id)initWithType:(ShopCartTableViewType)type;

// Allows the contents of the tableview to be initialized with that of a past order
- (id)initWithOrder:(NSDictionary*)order;

+ (CGFloat)heightForTableView;
+ (CGFloat)heightForTableViewWithOrder:(NSDictionary*)order;

@end

@protocol ShopCartTableViewDelegate <NSObject>
@optional
- (void)shopCartTableView:(ShopCartTableView*)shopCartTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)shopCartTableView:(ShopCartTableView*)shopCartTableView didCommitEditStyleForRowAtIndexPath:(NSIndexPath*)indexPath;
@end