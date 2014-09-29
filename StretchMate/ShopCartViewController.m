//
//  ShopCartViewController.m
//  Exersite
//
//  Created by James Eunson on 22/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCartViewController.h"
#import "ShopDetailViewController.h"
#import "UIAlertView+Blocks.h"
#import "ShopRequestQuoteViewController.h"
#import "ShopPaymentViewController.h"
#import "ExersiteSession.h"
#import "ShopDeliveryViewController.h"
#import "UIActionSheet+Blocks.h"

@interface ShopCartViewController ()

- (void)toggleEdit:(id)sender;
- (void)clearAllItems:(id)sender;

@end

@implementation ShopCartViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.scrollView = [[ShopCartScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [ShopCartScrollView containerHeightForCartScrollView]);
    _scrollView.cartDelegate = self;
    [self.view addSubview:_scrollView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    self.title = @"Cart";
    
    if([[[AppConfig sharedConfig] shopCartItems] count] > 0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)];
    }
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
}

#pragma mark - Private Methods
- (void)toggleEdit:(id)sender {
    self.editing = !_editing;
    
    [self.scrollView.cartItemsTableView setEditing:_editing animated:YES];
    
    if(_editing) { // Not editing -> Editing
        
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEdit:)] animated:YES];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Clear All" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllItems:)] animated:YES];
        
    } else { // Editing -> Not editing
        
        if([[[AppConfig sharedConfig] shopCartItems] count] > 0) {
            [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)] animated:YES];
        } else {
            [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        }
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)] animated:YES];
    }
    
    [self.scrollView setNeedsLayout];
    
//    NSLog(@"toggle edit: %d",_editing);
}

- (void)clearAllItems:(id)sender {
    
    RIButtonItem * confirmItem = [RIButtonItem itemWithLabel:@"Clear All"];
    confirmItem.action = ^{
        
        NSArray * cartItems = [[AppConfig sharedConfig] shopCartItems];
        for(NSDictionary * item in cartItems) {
            [[AppConfig sharedConfig] removeShopCartItem:item];
        }
        
        [self toggleEdit:nil];
        [self.scrollView updateContent];
    };
    
    UIAlertView * clearAllAlertView = [[UIAlertView alloc] initWithTitle:@"Clear All?" message:@"Are you sure you want to clear all items from your shopping list?" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:confirmItem, nil];
    [clearAllAlertView show];
}

#pragma mark - ShopCartScrollViewDelegate Methods
- (void)shopCartScrollView:(ShopCartScrollView *)detailScrollView didSelectCartItem:(NSDictionary *)cartItem {
    
    // Edit quantity, removes item from cart and re-adds it with new quantity
    RIButtonItem * editQuantityItem = [RIButtonItem itemWithLabel:@"Edit Quantity"];
    editQuantityItem.action = ^{
        
        RIButtonItem * confirmItem = [RIButtonItem itemWithLabel:@"Confirm"];
        
        __block UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Edit Quantity" message:@"Enter the quantity you wish to purchase of this product, between 1 and 10." cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:confirmItem, nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
        
        confirmItem.action = ^{
            
            NSString * userInput = [[alertView textFieldAtIndex:0] text];
//            NSLog(@"confirm with input: '%@'", [[alertView textFieldAtIndex:0] text]);
            
            if([userInput length] == 0 || [userInput integerValue] == 0 || [userInput integerValue] > 10) {
                UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a quantity value between 1 and 10." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorAlertView show];
                
            } else {
                
                [[AppConfig sharedConfig] removeShopCartItem:cartItem];
                [[AppConfig sharedConfig] addShopCartItem:cartItem[kShopCartItemProductKey] withQuantity:[userInput integerValue]];
                
                [self.scrollView.cartItemsTableView reloadData];
                [self.scrollView updateContent];
            }
        };
    };
    
    // Remove from cart
    RIButtonItem * removeFromCartItem = [RIButtonItem itemWithLabel:@"Remove from Cart"];
    removeFromCartItem.action = ^{
//        NSLog(@"Remove from cart");
        
        RIButtonItem * confirmRemoveItem = [RIButtonItem itemWithLabel:@"Remove"];
        confirmRemoveItem.action = ^{
            [[AppConfig sharedConfig] removeShopCartItem:cartItem];
            
            [self.scrollView.cartItemsTableView reloadData];
            [self.scrollView updateContent];
        };
        
        NSString * removeConfirmMessage = [NSString stringWithFormat:@"Are you sure you want to remove %@ from your cart?", cartItem[kShopCartItemProductKey][@"name"]];
        UIAlertView * confirmRemoveAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm Remove" message:removeConfirmMessage cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:confirmRemoveItem, nil];
        [confirmRemoveAlertView show];
    };
    
    // View product - pushes detail view controller
    RIButtonItem * viewProductDetailItem = [RIButtonItem itemWithLabel:@"View Product Detail"];
    viewProductDetailItem.action = ^{
        
        // Likewise detail view is not performed using the segue here, due to a propensity to
        // crash when several levels deep in the navigational stack
        
        NSDictionary * product = cartItem[kShopCartItemProductKey];
        ShopDetailViewController * detailViewController = [[ShopDetailViewController alloc] init];
        detailViewController.selectedItem = product;
        [self.navigationController pushViewController:detailViewController animated:YES];
    };
    
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] destructiveButtonItem:removeFromCartItem otherButtonItems:viewProductDetailItem, editQuantityItem, nil];
    [sheet showInView:self.view];
}

- (void)shopCartScrollView:(ShopCartScrollView*)detailScrollView didTapCheckoutButton:(ShopBigButton*)button {
//    [self performSegueWithIdentifier:@"ShopCartCheckoutSegue" sender:nil];
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        
        ShopDeliveryViewController * deliveryViewController = [[ShopDeliveryViewController alloc] init];
        [self.navigationController pushViewController:deliveryViewController animated:YES];
        
    } else {
        
        LoginCheckoutViewController * loginViewController = [[LoginCheckoutViewController alloc] init];
        loginViewController.delegate = self;
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
}

- (void)shopCartScrollView:(ShopCartScrollView*)detailScrollView didTapRequestQuoteButton:(ShopBigButton*)button {
//    [self performSegueWithIdentifier:@"ShopCartRequestQuoteSegue" sender:nil];
    
    ShopRequestQuoteViewController * controller = [[ShopRequestQuoteViewController alloc] init];
    [self .navigationController pushViewController:controller animated:YES];
}

- (void)shopCartScrollView:(ShopCartScrollView *)detailScrollView didRemoveCartItemFromTableView:(UITableView *)tableView {
    
    // Post-deletion method, should update navigation bar and edit mode if removal of item has caused
    // number of items stored in the user's cart to drop to zero
    if([[[AppConfig sharedConfig] shopCartItems] count] == 0) {
        [self toggleEdit:nil];
    }
}

#pragma mark - LoginControllerDelegate Methods
- (void)loginViewControllerDidLogin:(LoginViewController*)controller {
    
    ShopDeliveryViewController * deliveryViewController = [[ShopDeliveryViewController alloc] init];
    [self.navigationController pushViewController:deliveryViewController animated:YES];
}

@end
