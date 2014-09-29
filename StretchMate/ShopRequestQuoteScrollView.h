//
//  ShopRequestQuoteScrollView.h
//  Exersite
//
//  Created by James Eunson on 6/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopBigButton.h"
#import "ShopCartTableView.h"

#define kRequestDetailsDeliveryCountryKey @"deliveryCountry"
#define kRequestDetailsDeliveryCountryCodeKey @"deliveryCountryCode"
#define kRequestDetailsEmailKey @"email"

@protocol ShopRequestQuoteScrollViewDelegate;
@interface ShopRequestQuoteScrollView : UIScrollView <ShopCartTableViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) CALayer * titleBorder;
@property (nonatomic, strong) UILabel * requestQuoteBodyLabel;

@property (nonatomic, strong) CALayer * cartItemsTableViewTopBorder;
@property (nonatomic, strong) ShopCartTableView * cartItemsTableView;

@property (nonatomic, strong) UIImageView * cartItemsEmptyImageView;
@property (nonatomic, strong) UILabel * cartItemsEmptyMessageLabel;

@property (nonatomic, strong) UILabel * enterYourDetailsLabel;
@property (nonatomic, strong) CALayer * enterYourDetailsBorder;
@property (nonatomic, strong) UITableView * enterYourDetailsTableView;

@property (nonatomic, strong) ShopBigButton * requestQuoteButton;

@property (nonatomic, strong, readonly) UIToolbar * fieldToolbar;
@property (nonatomic, strong) NSMutableArray * deliveryCountries;
@property (nonatomic, strong) NSMutableDictionary * requestDetails;

@property (nonatomic, assign) __unsafe_unretained id<ShopRequestQuoteScrollViewDelegate> requestQuoteDelegate;

+ (CGFloat)heightForScrollView;

@end

@protocol ShopRequestQuoteScrollViewDelegate <NSObject>
- (void)shopRequestQuoteScrollView:(ShopRequestQuoteScrollView*)shopRequestQuoteScrollView didTapSubmitButton:(ShopBigButton*)submitButton;
@end