//
//  ShopChooseStoredAddressViewController.h
//  Exersite
//
//  Created by James Eunson on 12/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShopChooseStoredAddressViewControllerDelegate;
@interface ShopChooseStoredAddressViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray * storedAddresses;
@property (nonatomic, assign) __unsafe_unretained id<ShopChooseStoredAddressViewControllerDelegate> delegate;

@property (nonatomic, strong) UITableView * tableView;

@end

@protocol ShopChooseStoredAddressViewControllerDelegate <NSObject>
- (void)shopChooseStoredAddressViewController:(ShopChooseStoredAddressViewController*)controller didChooseStoredAddress:(NSDictionary*)address;
@end