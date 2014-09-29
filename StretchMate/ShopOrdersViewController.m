//
//  ShopOrdersViewController.m
//  Exersite
//
//  Created by James Eunson on 22/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopOrdersViewController.h"
#import "ExersiteHTTPClient.h"
#import "ProgressHUDHelper.h"
#import "ShopOrderDetailViewController.h"
#import "ExersiteSession.h"
#import "OrderedDictionary.h"
#import "UIImageView+AFNetworking.h"
#import "ProgramSectionHeaderView.h"
#import "AppConfig.h"
#import "ShopOrderCell.h"

@interface ShopOrdersViewController ()

@property (nonatomic, strong) ExersiteHTTPClient * httpClient;
@property (nonatomic, strong) OrderedDictionary * orders;

@property (nonatomic, strong) UIView * emptyView;

@property (nonatomic, strong) UIImageView * emptyViewImageView;
@property (nonatomic, strong) UILabel * emptyViewTitleLabel;
@property (nonatomic, strong) UILabel * emptyViewSubtitleLabel;

// Used for reading in dates from JSON
@property (nonatomic, strong) NSDateFormatter * dateFormatter;

// Used for formatting dates for display
@property (nonatomic, strong) NSDateFormatter * displayDateFormatter;

- (void)_loadOrders;
- (void)_reloadOrders;

@end

#define kCellReuseIdentifier @"orderCell"

@implementation ShopOrdersViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.httpClient = [[ExersiteHTTPClient alloc] init];
        self.orders = [[OrderedDictionary alloc] init];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
        
        self.displayDateFormatter = [[NSDateFormatter alloc] init];
        _displayDateFormatter.dateFormat = @"EEEE dd MM yyyy";
        _displayDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.emptyView = [[UIView alloc] init];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    _emptyView.hidden = YES;
    _emptyView.backgroundColor = RGBCOLOR(238, 238, 238);
    [self.view addSubview:_emptyView];
    
    self.emptyViewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-cart-empty-icon-ios7"]];
    [self.emptyView addSubview:_emptyViewImageView];
    
    self.emptyViewTitleLabel = [[UILabel alloc] init];
    _emptyViewTitleLabel.textColor = RGBCOLOR(57, 58, 70);
    _emptyViewTitleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    _emptyViewTitleLabel.backgroundColor = [UIColor clearColor];
    _emptyViewTitleLabel.text = @"You have no orders";
    _emptyViewTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyView addSubview:_emptyViewTitleLabel];
    
    self.emptyViewSubtitleLabel = [[UILabel alloc] init];
    _emptyViewSubtitleLabel.font = [UIFont systemFontOfSize:14.0f];
    _emptyViewSubtitleLabel.textColor = [UIColor grayColor];
    _emptyViewSubtitleLabel.backgroundColor = [UIColor clearColor];
    _emptyViewSubtitleLabel.numberOfLines = 0;
    _emptyViewSubtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _emptyViewSubtitleLabel.text = @"Any orders you place in the Exersite store will be displayed here.";
    _emptyViewSubtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyView addSubview:_emptyViewSubtitleLabel];
    
    self.tableView = [[UITableView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[ShopOrderCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    
    [self.view addSubview:_tableView];
    
    [self.view bringSubviewToFront:_emptyView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView, _emptyView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(_reloadOrders)];
    
    self.title = @"Orders";
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        [self _loadOrders];
        
    } else {
        
        self.emptyViewTitleLabel.text = @"Please login to view orders";
        self.emptyViewSubtitleLabel.text = @"Login to your Exersite account to view your shop orders.";
        [self.view setNeedsLayout];
        
        self.emptyView.hidden = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Layout empty view for current orientation
    CGSize sizeForEmptyViewTitleLabel = [self.emptyViewTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    CGSize sizeForEmptyViewSubtitleLabel = [self.emptyViewSubtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 80.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat startingPoint = (self.view.frame.size.height / 2) - ((_emptyViewImageView.frame.size.height + 20.0f + sizeForEmptyViewTitleLabel.height + 8.0f + sizeForEmptyViewSubtitleLabel.height) / 2);
    
    self.emptyViewImageView.frame = CGRectMake((self.view.frame.size.width / 2) - (_emptyViewImageView.frame.size.width / 2), startingPoint, _emptyViewImageView.frame.size.width, _emptyViewImageView.frame.size.height);
    
    self.emptyViewTitleLabel.frame = CGRectMake(8, _emptyViewImageView.frame.origin.y + _emptyViewImageView.frame.size.height + 20.0f, self.view.frame.size.width - 16.0f, sizeForEmptyViewTitleLabel.height);
    
    self.emptyViewSubtitleLabel.frame = CGRectMake((self.view.frame.size.width / 2) - ((self.view.frame.size.width - 80.0f) / 2), _emptyViewTitleLabel.frame.origin.y + _emptyViewTitleLabel.frame.size.height + 8.0f, self.view.frame.size.width - 80.0f, sizeForEmptyViewSubtitleLabel.height);
}

#pragma mark - Private Methods
- (void)_loadOrders {
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    [_httpClient retrieveOrders:^(NSDictionary *result) {
        
        // If any of the following exception conditions, display the error view
        if(!result || ![[result allKeys] containsObject:@"orders"]
           || ![result[@"orders"] isKindOfClass:[NSArray class]] || [result[@"orders"] count] == 0) {
            self.emptyView.hidden = NO;
            
        } else {
            
            // Group orders into days, using the associated date
            NSArray * rawOrders = result[@"orders"];
            for(NSDictionary * order in rawOrders) {
                
                NSMutableDictionary * mutableOrder = [order mutableCopy];
                
                NSDate * orderDate = [_dateFormatter dateFromString: order[@"date"]];
                NSString * displayDateString = [_displayDateFormatter stringFromDate:orderDate];
                
                // Add derived date information to the order, because it's expensive to reconstitute it later
                mutableOrder[kOrderDate] = orderDate;
                mutableOrder[kOrderHumanReadableDayDate] = displayDateString;
                
                if(![[_orders allKeys] containsObject:displayDateString]) {
                    _orders[displayDateString] = [[NSMutableArray alloc] init];
                }
                [_orders[displayDateString] addObject:mutableOrder];
            }
            
            self.emptyView.hidden = YES;
            [self.tableView reloadData];
        }
        
        [loadingView hide:YES];
    }];
}

- (void)_reloadOrders {
    
    [_orders removeAllObjects];
    [self _loadOrders];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString * keyForSection = [_orders allKeys][section];
    return [_orders[keyForSection] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_orders allKeys] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopOrderCell * cell = [_tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    NSString * keyForSection = [_orders allKeys][indexPath.section];
    NSDictionary * order = _orders[keyForSection][indexPath.row];
    
    cell.order = order;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 23)];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString * keyForSection = [_orders allKeys][section];
    return keyForSection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * keyForSection = [_orders allKeys][indexPath.section];
    NSDictionary * order = _orders[keyForSection][indexPath.row];
    
    ShopOrderDetailViewController * controller = [[ShopOrderDetailViewController alloc] init];
    controller.selectedOrder = order;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
