//
//  ShopOrderDetailScrollView.m
//  Exersite
//
//  Created by James Eunson on 20/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopOrderDetailScrollView.h"
#import "ShopOrdersViewController.h"
#import "ShopStoredAddressCell.h"

#define kTitleText @"Order Information"

#define kAddressText @"Selected Address"

#define kCellReuseIdentifier @"storedAddressCell"

@implementation ShopOrderDetailScrollView

- (id)initWithOrder:(NSDictionary *)order
{
    self = [super init];
    if (self) {
        self.order = order;
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = kTitleText;
        [self addSubview:_titleLabel];
        
        self.introductionLabel = [[UILabel alloc] init];
        _introductionLabel.font = [UIFont systemFontOfSize:13.0f];
        _introductionLabel.textColor = RGBCOLOR(99, 100, 109);
        _introductionLabel.backgroundColor = [UIColor clearColor];
        _introductionLabel.numberOfLines = 0;
        _introductionLabel.text = [NSString stringWithFormat:@"Order #%d placed on %@", [order[@"number"] intValue], order[kOrderHumanReadableDayDate]];
        _introductionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_introductionLabel];
        
        self.cartItemsTableViewTopBorder = [CALayer layer];
        _cartItemsTableViewTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_cartItemsTableViewTopBorder atIndex:100];
        
        self.cartItemsTableView = [[ShopCartTableView alloc] initWithOrder:self.order];
        _cartItemsTableView.shopCartTableDelegate = self;
        [self addSubview:_cartItemsTableView];
        
        self.addressTitleLabel = [[UILabel alloc] init];
        _addressTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _addressTitleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _addressTitleLabel.backgroundColor = [UIColor clearColor];
        _addressTitleLabel.numberOfLines = 0;
        _addressTitleLabel.text = kAddressText;
        [self addSubview:_addressTitleLabel];
        
        self.addressTableViewTopBorder = [CALayer layer];
        _addressTableViewTopBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_addressTableViewTopBorder atIndex:100];
        
        self.addressTableView = [[UITableView alloc] init];
        _addressTableView.delegate = self;
        _addressTableView.dataSource = self;
        _addressTableView.backgroundColor = RGBCOLOR(238, 238, 238);
        _addressTableView.separatorInset = UIEdgeInsetsZero;
        [_addressTableView registerClass:[ShopStoredAddressCell class] forCellReuseIdentifier:kCellReuseIdentifier];
        [self addSubview:_addressTableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.titleLabel.frame = CGRectMake(8, 8.0f, sizeForTitleLabel.width, sizeForTitleLabel.height);
    
    CGSize sizeForIntroductionLabel = [self.introductionLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _introductionLabel.frame = CGRectMake(8.0f, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 4.0f, self.frame.size.width - 16.0f, sizeForIntroductionLabel.height);
    
    _cartItemsTableViewTopBorder.frame = CGRectMake(0, _introductionLabel.frame.origin.y + _introductionLabel.frame.size.height + 19.0f, self.frame.size.width, 1.0f);
    
    _cartItemsTableView.frame = CGRectMake(0, _cartItemsTableViewTopBorder.frame.origin.y + _cartItemsTableViewTopBorder.frame.size.height, self.frame.size.width, [ShopCartTableView heightForTableViewWithOrder:_order]);
    
    CGSize sizeForAddressTitleLabel = [_addressTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    _addressTitleLabel.frame = CGRectMake(8.0f, _cartItemsTableView.frame.origin.y + _cartItemsTableView.frame.size.height + 20.0f, self.frame.size.width - 16.0f, sizeForAddressTitleLabel.height);
    
    _addressTableViewTopBorder.frame = CGRectMake(0, _addressTitleLabel.frame.origin.y + _addressTitleLabel.frame.size.height + 19.0f, self.frame.size.width, 1.0f);
    
    _addressTableView.frame = CGRectMake(0, _addressTableViewTopBorder.frame.origin.y + _addressTableViewTopBorder.frame.size.height, self.frame.size.width, [ShopStoredAddressCell heightForCellWithStoredAddress:self.order[@"address"] displayingOnPaymentPage:YES]);
    
    self.contentSize = CGSizeMake(self.frame.size.width, [[self class] heightForScrollViewWithOrder:_order]);
}

+ (CGFloat)heightForScrollViewWithOrder:(NSDictionary*)order {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 8.0f;
    
    NSString * subtitleTextForOrder = [NSString stringWithFormat:@"Order #%d placed on %@", order[@"number"], order[kOrderHumanReadableDayDate]];
    
    heightAccumulator += [kTitleText sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]].height + 8.0f;
    heightAccumulator += [subtitleTextForOrder sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0f;
    
    heightAccumulator += [ShopCartTableView heightForTableViewWithOrder:order];
    
    heightAccumulator += 20.0f + [kAddressText sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]].height + 20.0f;
    heightAccumulator += 1.0f + [ShopStoredAddressCell heightForCellWithStoredAddress:order[@"address"] displayingOnPaymentPage:YES] +  20.0f;
    
    return heightAccumulator;
}

#pragma mark - ShopCartTableViewDelegate Methods
- (void)shopCartTableView:(ShopCartTableView*)shopCartTableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopStoredAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    cell.storedAddress = self.order[@"address"];
    cell.selectedAddress = YES;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ShopStoredAddressCell heightForCellWithStoredAddress:self.order[@"address"] displayingOnPaymentPage:YES];
}


@end
