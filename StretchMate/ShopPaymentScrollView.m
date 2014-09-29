//
//  ShopPaymentScrollView.m
//  Exersite
//
//  Created by James Eunson on 12/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopPaymentScrollView.h"
#import "ShopStoredAddressCell.h"
#import "ProgressHUDHelper.h"
//#import "UIAlertView+Blocks.h"

#define kCellReuseIdentifier @"storedAddressCell"

#define kTitleText @"Payment"
#define kIntroductionText @"Enter your payment information below. You will have an opportunity to confirm your order items and delivery address before your card is charged."

#define kStripeViewHeight 44.0f

@interface ShopPaymentScrollView ()
- (void)didTapNextStepButton:(id)sender;
@end

@implementation ShopPaymentScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.stepView = [[ShopCheckoutStepView alloc] init];
        _stepView.selectedStep = ShopCheckoutStepPayment;
        [self addSubview:_stepView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = kTitleText;
        [self addSubview:_titleLabel];
        
        self.introductionLabel = [[UILabel alloc] init];
        _introductionLabel.text = kIntroductionText;
        _introductionLabel.font = [UIFont systemFontOfSize:13.0f];
        _introductionLabel.textColor = RGBCOLOR(99, 100, 109);
        _introductionLabel.backgroundColor = [UIColor clearColor];
        _introductionLabel.numberOfLines = 0;
        _introductionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_introductionLabel];
        
        self.orderTotalLabel = [[UILabel alloc] init];
        _orderTotalLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _orderTotalLabel.textColor = RGBCOLOR(57, 58, 70);
        _orderTotalLabel.text = @"Order Total";
        _orderTotalLabel.backgroundColor = [UIColor clearColor];
        _orderTotalLabel.numberOfLines = 0;
        _orderTotalLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_orderTotalLabel];
        
        self.stripeView = [[STPView alloc] initWithFrame:CGRectZero andKey:@"pk_test_gZ9uMPBG7OpMQhGJfiCVziS7"];
        _stripeView.delegate = self;
        [self addSubview:self.stripeView];
        
        self.nextStepButton = [[ShopBigButton alloc] init];
        _nextStepButton.type = ShopBigButtonTypeNextStep;
        [_nextStepButton addTarget:self action:@selector(didTapNextStepButton:) forControlEvents:UIControlEventTouchUpInside];
        _nextStepButton.enabled = NO;
        _nextStepButton.alpha = 0.5f;
        [self addSubview:_nextStepButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.stepView.frame = CGRectMake(0, 0, self.frame.size.width, 33.0f);
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.titleLabel.frame = CGRectMake(8, _stepView.frame.size.height + 12.0f, sizeForTitleLabel.width, sizeForTitleLabel.height);
    
    CGSize sizeForIntroductionLabel = [self.introductionLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _introductionLabel.frame = CGRectMake(8.0f, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 8.0f, self.frame.size.width - 16.0f, sizeForIntroductionLabel.height);
    
    CGSize sizeForOrderTotalLabel = [self.orderTotalLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _orderTotalLabel.frame = CGRectMake(8.0f, _introductionLabel.frame.origin.y + _introductionLabel.frame.size.height + 20.0f, self.frame.size.width - 16.0f, sizeForOrderTotalLabel.height);
    
    _stripeView.frame = CGRectMake(8.0f, _orderTotalLabel.frame.origin.y + _orderTotalLabel.frame.size.height + 8.0f, self.frame.size.width, kStripeViewHeight);
    _nextStepButton.frame = CGRectMake(8.0f, _stripeView.frame.origin.y + _stripeView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
    
    self.contentSize = CGSizeMake(self.frame.size.width, [[self class] heightForScrollViewWithSelectedAddress:_selectedAddress]);
}

+ (CGFloat)heightForScrollViewWithSelectedAddress:(NSDictionary*)selectedAddress {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 33.0f; // Base value is step indicator
    
    heightAccumulator += (12.0f + [kTitleText sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]].height);
    heightAccumulator += (8.0f + [kIntroductionText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    heightAccumulator += (8.0f + [kOrderTotalTemplateText sizeWithFont:[UIFont boldSystemFontOfSize:13.0f]].height); // Assuming one line for order total
    
    heightAccumulator += (8.0f + kStripeViewHeight + 8.0f + 44.0f + 20.0f); // Bottom padding
    
    return heightAccumulator;
}

#pragma mark - STPViewDelegate Methods
- (void) stripeView:(STPView*)view withCard:(PKCard *)card isValid:(BOOL)valid {
    
    if(valid) {
        _nextStepButton.enabled = YES;
        _nextStepButton.alpha = 1.0f;
    } else {
        _nextStepButton.enabled = NO;
        _nextStepButton.alpha = 0.5f;
    }
}

#pragma mark - Private Methods
- (void)didTapNextStepButton:(id)sender {
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        
        [loadingView hide:YES];
        
        if (error) {

            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred while processing your card. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
        } else {
            
            if([self.paymentDelegate respondsToSelector:@selector(shopPaymentScrollView:didReceiveToken:)]) {
                [self.paymentDelegate performSelector:@selector(shopPaymentScrollView:didReceiveToken:) withObject:self withObject:token.tokenId];
            }
        }
    }];
}

@end
