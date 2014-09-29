//
//  ShopCartTableView.m
//  Exersite
//
//  Created by James Eunson on 6/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCartTableView.h"
#import "ShopCartItemCell.h"
#import "ShopCartTotalCell.h"
#import "ShopDeliveryScrollView.h"

#define kCartCellReuseIdentifier @"cartItemCell"
#define kCartTotalCellReuseIdentifier @"cartTotalCell"

@implementation ShopCartTableView

- (id)initWithType:(ShopCartTableViewType)type {
    self = [self init];
    if(self) {
        self.type = type;
    }
    return self;
}

- (id)initWithOrder:(NSDictionary*)order {
    self = [self init];
    if(self) {
        self.type = ShopCartTableViewTypeOrder;
        self.order = order;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.dataSource = self;
        self.delegate = self;
        
        self.separatorInset = UIEdgeInsetsZero;
        self.scrollEnabled = NO;
        
        [self registerClass:[ShopCartItemCell class] forCellReuseIdentifier:kCartCellReuseIdentifier];
        [self registerClass:[ShopCartTotalCell class] forCellReuseIdentifier:kCartTotalCellReuseIdentifier];
    }
    return self;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.order) {
        return [self.order[@"items"] count] + 3;
    } else {
        return [[[AppConfig sharedConfig] shopCartItems] count] + 3;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemsCount = -1;
    if(self.order) {
        itemsCount = [self.order[@"items"] count];
    } else {
        itemsCount = [[[AppConfig sharedConfig] shopCartItems] count];
    }
    
    if(indexPath.row < itemsCount) { // [[[AppConfig sharedConfig] shopCartItems] count]
        
        NSDictionary * itemDict = nil;
        if(self.order) {
            itemDict = _order[@"items"][indexPath.row];
        } else {
            itemDict = [[AppConfig sharedConfig] shopCartItems][indexPath.row];
        }
        
        ShopCartItemCell * cell = [tableView dequeueReusableCellWithIdentifier:kCartCellReuseIdentifier forIndexPath:indexPath];
        cell.cartItemDict = itemDict;
        
        if(self.type == ShopCartTableViewTypeNormal) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
        
    } else {
        
        ShopCartTotalCell * cell = [tableView dequeueReusableCellWithIdentifier:kCartTotalCellReuseIdentifier forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        
        cell.textLabel.textColor = RGBCOLOR(57, 58, 70);
        cell.detailTextLabel.textColor = RGBCOLOR(57, 58, 70);
        
        double cartSubtotal = [[AppConfig sharedConfig] shopCartSubtotal];
        
        if(indexPath.row == itemsCount) { // Subtotal
            
            cell.textLabel.text = @"Subtotal";
            if(self.order) {
                double orderSubtotalDecimal = [self.order[@"subtotal"] doubleValue] / 100;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"A$%.2f", orderSubtotalDecimal];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"A$%.2f", cartSubtotal];
            }
            
        } else if(indexPath.row == itemsCount + 1) { // Shipping
            
            // If defined, display international shipping information
            if(self.order) {
                
                NSString * deliveryCountry = self.order[@"address"][kDeliveryCountryName];
                cell.textLabel.text = [NSString stringWithFormat:@"Shipping to %@", deliveryCountry];
                
                double orderShippingDecimal = [self.order[@"shipping"] doubleValue] / 100;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"A$%.2f", orderShippingDecimal];
                
            } else {
                if(self.internationalShippingAmount && self.internationalShippingCountry) {
                    cell.textLabel.text = [NSString stringWithFormat: @"Shipping to %@", _internationalShippingCountry];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"A$%.2f", [_internationalShippingAmount doubleValue]];
                    
                } else {
                    cell.textLabel.text = @"Shipping (within Australia)";
                    cell.detailTextLabel.text = @"A$10.00";
                }
            }
            
        } else if(indexPath.row == itemsCount + 2) { // Total
            
            cell.textLabel.text = @"Total";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            
            cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            
            if(self.order) {
                
                double orderTotalDecimal = [self.order[@"total"] doubleValue] / 100;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"A$%.2f", orderTotalDecimal];
                
            } else {
                // If defined, show correct total including shipping price for delivery country
                if(self.internationalShippingCountry && self.internationalShippingAmount) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"A$%.2f", (cartSubtotal + [_internationalShippingAmount doubleValue])];
                } else {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"A$%.2f", (cartSubtotal + 10.0)];
                }
            }
            
            cell.detailTextLabel.textColor = kTintColour;
        }
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate Methods
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Orders are read-only
    if(self.order) {
        return NO;
    } else {
        if(indexPath.row < [[[AppConfig sharedConfig] shopCartItems] count]) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger itemsCount = -1;
    if(self.order) {
        itemsCount = [self.order[@"items"] count];
    } else {
        itemsCount = [[[AppConfig sharedConfig] shopCartItems] count];
    }
    
    if(indexPath.row < itemsCount) {
        if([self.shopCartTableDelegate respondsToSelector:@selector(shopCartTableView:didSelectRowAtIndexPath:)]) {
            [self.shopCartTableDelegate performSelector:@selector(shopCartTableView:didSelectRowAtIndexPath:) withObject:self withObject:indexPath];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemsCount = -1;
    if(self.order) {
        itemsCount = [self.order[@"items"] count];
    } else {
        itemsCount = [[[AppConfig sharedConfig] shopCartItems] count];
    }
    
    if(indexPath.row < itemsCount) {
        
        NSDictionary * itemForRow = [[AppConfig sharedConfig] shopCartItems][indexPath.row];
        [[AppConfig sharedConfig] removeShopCartItem:itemForRow];
        
        if([self.shopCartTableDelegate respondsToSelector:@selector(shopCartTableView:didCommitEditStyleForRowAtIndexPath:)]) {
            [self.shopCartTableDelegate performSelector:@selector(shopCartTableView:didCommitEditStyleForRowAtIndexPath:) withObject:self withObject:indexPath];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemsCount = -1;
    if(self.order) {
        itemsCount = [self.order[@"items"] count];
    } else {
        itemsCount = [[[AppConfig sharedConfig] shopCartItems] count];
    }
    
    if(indexPath.row < itemsCount) {
        
        NSDictionary * itemForRow = nil;
        if(self.order) {
            itemForRow = self.order[@"items"][indexPath.row];
        } else {
            itemForRow = [[AppConfig sharedConfig] shopCartItems][indexPath.row];
        }
        return [ShopCartItemCell heightForCellWithCartItem:itemForRow];
        
    } else {
        return 33.0f;
    }
}

+ (CGFloat)heightForTableView {
    
    CGFloat heightAccumulator = (3 * 33.0f); // Starting value is mandatory 3 final cells
    for(NSDictionary * cartItem in [[AppConfig sharedConfig] shopCartItems]) {
        heightAccumulator += [ShopCartItemCell heightForCellWithCartItem:cartItem];
    }
    
    return heightAccumulator;
}

+ (CGFloat)heightForTableViewWithOrder:(NSDictionary *)order {
    
    CGFloat heightAccumulator = (3 * 33.0f); // Starting value is mandatory 3 final cells
    for(NSDictionary * cartItem in order[@"items"]) {
        heightAccumulator += [ShopCartItemCell heightForCellWithCartItem:cartItem];
    }
    
    return heightAccumulator;
}

@end
