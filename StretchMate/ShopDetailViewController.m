//
//  ShopDetailViewController.m
//  StretchMate
//
//  Created by James Eunson on 4/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopDetailViewController.h"
#import "ShopDetailScrollView.h"
#import "UIAlertView+Blocks.h"
#import "RemoteImageViewController.h"
#import "ShopViewController.h"
#import "ShopCartViewController.h"
#import "ShopRequestQuoteViewController.h"

@interface ShopDetailViewController ()

- (void)showCart;

@end

@implementation ShopDetailViewController

- (id)initWithMode:(ShopDetailMode)mode {
    self = [super init];
    if(self) {
        self.mode = mode;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    self.scrollView = [[ShopDetailScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.scrollView.selectedItem = self.selectedItem;
    
    self.scrollView.shopDelegate = self;
    [self.view addSubview:self.scrollView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(self.mode == ShopDetailModeModal) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    }
    
    self.navigationItem.title = self.selectedItem[@"name"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([[AppConfig sharedConfig] isProductInCart:self.selectedItem]) {
        self.scrollView.addToCartButton.type = ShopBigButtonTypeItemInCart;
    } else {
        self.scrollView.addToCartButton.type = ShopBigButtonTypeAddToCart;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.scrollView setNeedsLayout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShopDetailImageViewSegue"]) {
        
        RemoteImageViewController * destinationViewController = segue.destinationViewController;
        NSDictionary * parameters = @{ kRemoteImageViewImageUrl : [NSURL URLWithString: self.selectedItem[@"image"]], kRemoteImageViewTitle: self.selectedItem[@"name"], kRemoteImageViewSubtitle : self.selectedItem[@"category"] };
        destinationViewController.parameters = parameters;
        destinationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
    } else if([segue.identifier isEqualToString:@"ShopDetailCategorySegue"]) {
        
        ShopViewController * destinationViewController = segue.destinationViewController;
        destinationViewController.mode = ShopViewControllerModeCategory;
        destinationViewController.selectedCategoryItem = self.selectedItem;
        
//        destinationViewController.selectedCategorySlug = self.selectedItem[@"related"];
//        destinationViewController.selectedCategoryTitle = self.selectedItem[@"category"];
    }
}

#pragma mark - ShopDetailScrollViewDelegate Methods
- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didAddProductToCart:(NSDictionary*)product {
    
    if([[AppConfig sharedConfig] isProductInCart:product]) { // Cannot add again
        [self showCart];
        return;
    }
    
    [[AppConfig sharedConfig] addShopCartItem:product withQuantity:1];
    self.scrollView.addToCartButton.type = ShopBigButtonTypeItemInCart;
    
    RIButtonItem * viewCartItem = [RIButtonItem itemWithLabel:@"View Cart"];
    viewCartItem.action = ^{
        [self showCart];
    };
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Added to Cart" message:[NSString stringWithFormat:@"Added %@ to your cart.", product[@"name"]] cancelButtonItem:[RIButtonItem itemWithLabel:@"Close"] otherButtonItems:viewCartItem, nil];
    [alertView show];
}

- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didTapSubtitleButtonWithProduct:(NSDictionary*)product {
    [self performSegueWithIdentifier:@"ShopDetailCategorySegue" sender:product];    
}

- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didZoomImageWithProduct:(NSDictionary*)product {
//    [self performSegueWithIdentifier:@"ShopDetailImageViewSegue" sender:product];
    
    RemoteImageViewController * imageViewController = [[RemoteImageViewController alloc] init];
    NSDictionary * parameters = @{ kRemoteImageViewImageUrl : [NSURL URLWithString: self.selectedItem[@"image"]], kRemoteImageViewTitle: self.selectedItem[@"name"], kRemoteImageViewSubtitle : self.selectedItem[@"category"] };
    imageViewController.parameters = parameters;
    imageViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:imageViewController animated:YES completion:nil];
}

- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didTapRequestQuoteButtonWithProduct:(NSDictionary*)product {
    
    // Removed segue here for same reason, doesn't work once a few levels deep in the navigation stack
    ShopRequestQuoteViewController * controller = [[ShopRequestQuoteViewController alloc] init];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didTapViewRelatedButtonWithProduct:(NSDictionary*)product {
    [self performSegueWithIdentifier:@"ShopDetailCategorySegue" sender:product];
}

- (void)shopDetailScrollView:(ShopDetailScrollView *)detailScrollView didSelectRelatedProduct:(NSDictionary*)product {
    
    ShopDetailViewController * detailViewController = [[ShopDetailViewController alloc] init];
    detailViewController.selectedItem = product;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Private Methods
- (void)showCart {
    
    // Required because calling the segue from different points can cause a crash
    ShopCartViewController * cartViewController = [[ShopCartViewController alloc] init];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:cartViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
