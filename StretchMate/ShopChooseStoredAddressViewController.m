//
//  ShopChooseStoredAddressViewController.m
//  Exersite
//
//  Created by James Eunson on 12/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopChooseStoredAddressViewController.h"
#import "ShopStoredAddressCell.h"

#define kCellReuseIdentifier @"storedAddressCell"

@interface ShopChooseStoredAddressViewController ()

@end

@implementation ShopChooseStoredAddressViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = RGBCOLOR(238, 238, 238);
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorInset = UIEdgeInsetsZero;
    
    [_tableView registerClass:[ShopStoredAddressCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    [self.view addSubview:_tableView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Choose Address";
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.storedAddresses count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopStoredAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    NSDictionary * selectedAddress = self.storedAddresses[indexPath.row];
    cell.storedAddress = selectedAddress;
    cell.addressNumber = (indexPath.row + 1);
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * selectedAddress = self.storedAddresses[indexPath.row];
    
    if([self.delegate respondsToSelector:@selector(shopChooseStoredAddressViewController:didChooseStoredAddress:)]) {
        [self.delegate performSelector:@selector(shopChooseStoredAddressViewController:didChooseStoredAddress:) withObject:self withObject:selectedAddress];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ShopStoredAddressCell heightForCellWithStoredAddress:self.storedAddresses[indexPath.row] displayingOnPaymentPage:NO];
}

@end
