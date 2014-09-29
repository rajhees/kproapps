//
//  ShopStoredAddressCell.h
//  Exersite
//
//  Created by James Eunson on 12/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopStoredAddressCell : UITableViewCell

@property (nonatomic, strong) NSDictionary * storedAddress;
@property (nonatomic, strong) UILabel * addressLabel;

@property (nonatomic, assign) NSInteger addressNumber;
@property (nonatomic, assign) BOOL selectedAddress; // Used in ShopPaymentScrollView

+ (CGFloat)heightForCellWithStoredAddress:(NSDictionary*)storedAddress displayingOnPaymentPage:(BOOL)displayingOnPaymentPage;

@end
