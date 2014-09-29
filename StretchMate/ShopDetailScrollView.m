//
//  ShopDetailScrollView.m
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopDetailScrollView.h"
#import "ShopDetailTagView.h"
#import "ExerciseGalleryView.h"
#import "ShopBuyButton.h"
#import "ExerciseBlueButton.h"
#import "UIImageView+AFNetworking.h"
#import "ShopItemCell.h"
#import "ExersiteHTTPClient.h"

#define kProductImageHeight 190.0f
#define kRelatedCellReuseIdentifier @"relatedCell"

@interface ShopDetailScrollView()

- (void)didTapAddToCartButton:(id)sender;
- (void)didTapGalleryButton:(id)sender;
- (void)didTapSubtitleButton:(id)sender;
- (void)didTapRequestQuoteButton:(id)sender;
- (void)didTapViewRelatedButton:(id)sender;

- (void)loadItemImage;
- (void)loadRelatedItems;

@property (nonatomic, assign) CGFloat collectionViewHeight;

@end

@implementation ShopDetailScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentSize = CGSizeMake(0, 0);
        self.backgroundColor = [UIColor clearColor];
        
        self.relatedItems = [[NSMutableArray alloc] init];
        self.collectionViewHeight = -1.0f;
        
        self.titleLabel = [[UILabel alloc] init];
        
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        
        [self addSubview:_titleLabel];
        
        self.subtitleButton = [[UIButton alloc] init];
        [_subtitleButton addTarget:self action:@selector(didTapSubtitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_subtitleButton];
        
        self.subtitleLabel = [[UILabel alloc] init];
        
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        _subtitleLabel.textColor = RGBCOLOR(142, 142, 149);
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        
        [_subtitleButton addSubview:_subtitleLabel];
        
        self.subtitleArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"program-item-arrow-ios7"]];
        [_subtitleButton addSubview:_subtitleArrowImageView];
        
        self.priceLabelContainerView = [[UIView alloc] init];
        _priceLabelContainerView.backgroundColor = [UIColor whiteColor];
        _priceLabelContainerView.layer.borderColor = [RGBCOLOR(221, 221, 221) CGColor];
        _priceLabelContainerView.layer.borderWidth = 1.0f;
        _priceLabelContainerView.layer.masksToBounds = YES;
        _priceLabelContainerView.layer.cornerRadius = 4.0f;
        
        self.priceLabel = [[UILabel alloc] init];
        
        _priceLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _priceLabel.textColor = kTintColour;
        _priceLabel.backgroundColor = [UIColor clearColor];
        
        [_priceLabelContainerView addSubview:_priceLabel];
        [self addSubview:_priceLabelContainerView];
        
        self.addToCartButton = [[ShopBigButton alloc] init];
        _addToCartButton.type = ShopBigButtonTypeAddToCart;
        [_addToCartButton addTarget:self action:@selector(didTapAddToCartButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addToCartButton];
        
        self.itemImageContainerView = [[UIView alloc] init];
        _itemImageContainerView.layer.borderColor = [RGBCOLOR(221, 221, 221) CGColor];
        _itemImageContainerView.layer.borderWidth = 1.0f;
        _itemImageContainerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_itemImageContainerView];
        
        self.itemImageLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_itemImageContainerView addSubview:_itemImageLoadingView];
        
        self.itemImageView = [[UIImageView alloc] init];
        _itemImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_itemImageContainerView addSubview:_itemImageView];
        
        self.itemImageZoomButton = [[UIButton alloc] init];
        [_itemImageZoomButton setImage:[UIImage imageNamed:@"shop-detail-image-zoom-button"] forState:UIControlStateNormal];
        [_itemImageZoomButton addTarget:self action:@selector(didTapGalleryButton:) forControlEvents:UIControlEventTouchUpInside];
        [_itemImageContainerView addSubview:_itemImageZoomButton];
        
        UITapGestureRecognizer * imageContainerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGalleryButton:)];
        [_itemImageContainerView addGestureRecognizer:imageContainerTapGestureRecognizer];
        self.shippingDetailsLabel = [[UILabel alloc] init];
        
        _shippingDetailsLabel.font = [UIFont systemFontOfSize:13.0f];
        _shippingDetailsLabel.textColor = RGBCOLOR(142, 142, 149);
        _shippingDetailsLabel.backgroundColor = [UIColor clearColor];
        _shippingDetailsLabel.numberOfLines = 0;
        _shippingDetailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:_shippingDetailsLabel];
        
        self.requestQuoteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_requestQuoteButton setTitle:@"Request a quote" forState:UIControlStateNormal];
        [_requestQuoteButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_requestQuoteButton setTintColor:RGBCOLOR(0, 136, 204)];
        [_requestQuoteButton addTarget:self action:@selector(didTapRequestQuoteButton:) forControlEvents:UIControlEventTouchUpInside];
        _requestQuoteButton.layer.borderColor = [RGBCOLOR(0, 136, 204) CGColor];
        _requestQuoteButton.layer.borderWidth = 1.0f;
        _requestQuoteButton.layer.cornerRadius = 4.0f;
        [self addSubview:_requestQuoteButton];
        
        self.descriptionSeparatorBorderLayer = [CALayer layer];
        [_descriptionSeparatorBorderLayer setBackgroundColor:RGBCOLOR(204, 204, 204).CGColor];
        [self.layer addSublayer:_descriptionSeparatorBorderLayer];
        
        self.descriptionTitleLabel = [[UILabel alloc] init];
        _descriptionTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _descriptionTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _descriptionTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_descriptionTitleLabel];
        
        self.descriptionBodyLabel = [[UILabel alloc] init];
        _descriptionBodyLabel.font = [UIFont systemFontOfSize:14.0f];
        _descriptionBodyLabel.textColor = RGBCOLOR(99, 100, 109);
        _descriptionBodyLabel.backgroundColor = [UIColor clearColor];
        _descriptionBodyLabel.numberOfLines = 0;
        _descriptionBodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_descriptionBodyLabel];
        
        self.relatedSeparatorBorderLayer = [CALayer layer];
        [_relatedSeparatorBorderLayer setBackgroundColor:RGBCOLOR(204, 204, 204).CGColor];
        [self.layer addSublayer:_relatedSeparatorBorderLayer];
        
        self.relatedTitleLabel = [[UILabel alloc] init];
        _relatedTitleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        _relatedTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _relatedTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_relatedTitleLabel];
        
        self.relatedTextButton = [[UIButton alloc] init];
        [_relatedTextButton setTitle:@"View all related items" forState:UIControlStateNormal];
        [_relatedTextButton setTintColor:RGBCOLOR(0, 136, 204)];
        [_relatedTextButton addTarget:self action:@selector(didTapViewRelatedButton:) forControlEvents:UIControlEventTouchUpInside];
        _relatedTextButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_relatedTextButton setTitleColor:RGBCOLOR(0, 136, 204) forState:UIControlStateNormal];
        [self addSubview:_relatedTextButton];
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.relatedCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _relatedCollectionView.delegate = self;
        _relatedCollectionView.dataSource = self;
        
        [self.relatedCollectionView registerClass:[ShopItemCell class] forCellWithReuseIdentifier:kRelatedCellReuseIdentifier];
        [self.relatedCollectionView setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_relatedCollectionView];
        
        [self bringSubviewToFront:_addToCartButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(!self.selectedItem) return; // Pointless without selectedItem present
    
    CGFloat calculatedHeight = [[self class] containerHeightWithSelectedItem:self.selectedItem];    
    
    self.contentSize = CGSizeMake(self.frame.size.width, calculatedHeight + 120);
    
    CGSize titleTextSize = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 90.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.titleLabel.frame = CGRectMake(8, 8, titleTextSize.width, titleTextSize.height);
    
    CGSize subtitleTextSize = [self.subtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 90.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.subtitleLabel.frame = CGRectMake(0, 0, subtitleTextSize.width, subtitleTextSize.height);
    
    self.subtitleArrowImageView.frame = CGRectMake(_subtitleLabel.frame.origin.x + _subtitleLabel.frame.size.width + 6.0f, 0, _subtitleArrowImageView.frame.size.width, _subtitleArrowImageView.frame.size.height);
    
    self.subtitleButton.frame = CGRectMake(8, _titleLabel.frame.origin.y + _titleLabel.frame.size.height, subtitleTextSize.width + _subtitleArrowImageView.frame.size.width + 6.0f, MAX(_subtitleLabel.frame.size.height, _subtitleArrowImageView.frame.size.height));
    
    CGSize priceTextSize = [self.priceLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(80.0f, 20) lineBreakMode:NSLineBreakByTruncatingTail];
    self.priceLabel.frame = CGRectMake(8.0f, 8.0f, priceTextSize.width, priceTextSize.height);
    
    CGFloat priceContainerViewWidth = priceTextSize.width + 30.0f;
    _priceLabelContainerView.frame = CGRectMake(self.frame.size.width - priceContainerViewWidth + 10.0f, 8, priceContainerViewWidth, priceTextSize.height + 16.0f);
    
    // Start and end of container are outside view bounds, to hide edge borders
    _itemImageContainerView.frame = CGRectMake(-1, _subtitleButton.frame.origin.y + _subtitleButton.frame.size.height + 10.0f, self.frame.size.width + 2.0f, kProductImageHeight + 16.0f);
    _itemImageView.frame = CGRectMake(1, 8.0f, self.frame.size.width, kProductImageHeight);
    _itemImageLoadingView.frame = CGRectMake((_itemImageContainerView.frame.size.width / 2) - (48.0f / 2), (_itemImageContainerView.frame.size.height / 2) - (48.0f / 2), 48.0f, 48.0f);
    
    _itemImageZoomButton.frame = CGRectMake(_itemImageContainerView.frame.size.width - 35.0f - 8.0f, _itemImageContainerView.frame.size.height - 8.0f - 36.0f, 35.0f, 36.0f);
    
    _addToCartButton.frame = CGRectMake(8.0f, _itemImageContainerView.frame.origin.y + _itemImageContainerView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        self.shippingDetailsLabel.text = @"Shipping is $10 within Australia. Intl. shipping available on request.";
    } else {
        self.shippingDetailsLabel.text = @"Shipping is $10 within Australia.\nIntl. shipping available on request.";
    }
    
    CGSize shippingDetailsTextSize = [_shippingDetailsLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 20.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _shippingDetailsLabel.frame = CGRectMake(10.0f, _addToCartButton.frame.origin.y + _addToCartButton.frame.size.height + 8.0f, shippingDetailsTextSize.width, shippingDetailsTextSize.height);
    
    CGSize requestQuoteTextSize = [_requestQuoteButton.titleLabel.text  sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    _requestQuoteButton.frame = CGRectMake(8.0f, _shippingDetailsLabel.frame.origin.y + _shippingDetailsLabel.frame.size.height + 8.0f, requestQuoteTextSize.width + 16.0f, requestQuoteTextSize.height + 10.0f);
    
    // Description
    _descriptionSeparatorBorderLayer.frame = CGRectMake(0, _requestQuoteButton.frame.origin.y + _requestQuoteButton.frame.size.height + 12.0f, self.frame.size.width, 1.0f);
    
    CGSize descriptionTitleLabelSize = [_descriptionTitleLabel.text  sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]];
    _descriptionTitleLabel.frame = CGRectMake(8.0f, _descriptionSeparatorBorderLayer.frame.origin.y + _descriptionSeparatorBorderLayer.frame.size.height + 8.0f, descriptionTitleLabelSize.width, descriptionTitleLabelSize.height);
    
    CGSize descriptionBodyLabelSize = [_descriptionBodyLabel.text  sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _descriptionBodyLabel.frame = CGRectMake(8.0f, _descriptionTitleLabel.frame.origin.y + _descriptionTitleLabel.frame.size.height + 8.0f, descriptionBodyLabelSize.width, descriptionBodyLabelSize.height);
    
    // Related
    _relatedSeparatorBorderLayer.frame = CGRectMake(0, _descriptionBodyLabel.frame.origin.y + _descriptionBodyLabel.frame.size.height + 12.0f, self.frame.size.width, 1.0f);
    
    CGSize relatedTitleLabelSize = [_relatedTitleLabel.text  sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]];
    _relatedTitleLabel.frame = CGRectMake(8.0f, _relatedSeparatorBorderLayer.frame.origin.y + _relatedSeparatorBorderLayer.frame.size.height + 8.0f, relatedTitleLabelSize.width, relatedTitleLabelSize.height);
    
    CGSize relatedTextButtonTitleSize = [_relatedTextButton.titleLabel.text  sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    _relatedTextButton.frame = CGRectMake(self.frame.size.width - relatedTextButtonTitleSize.width - 8.0f, _relatedSeparatorBorderLayer.frame.origin.y + _relatedSeparatorBorderLayer.frame.size.height + 8.0f, relatedTextButtonTitleSize.width, relatedTextButtonTitleSize.height);
    
    if(self.collectionViewHeight == -1.0f) {
        _relatedCollectionView.frame = CGRectMake(0, _relatedTitleLabel.frame.origin.y + _relatedTitleLabel.frame.size.height + 8.0f, self.frame.size.width, kProgramCellHeight);
    } else {
        _relatedCollectionView.frame = CGRectMake(0, _relatedTitleLabel.frame.origin.y + _relatedTitleLabel.frame.size.height + 8.0f, self.frame.size.width, _collectionViewHeight);
    }
}

- (void)setSelectedItem:(NSDictionary*)selectedItem {
    _selectedItem = selectedItem;
    
    self.titleLabel.text = self.selectedItem[@"name"];
    self.subtitleLabel.text = self.selectedItem[@"category"];
    self.priceLabel.text = [NSString stringWithFormat:@"$A%.2f", [self.selectedItem[@"price"] floatValue]];
    
    self.descriptionTitleLabel.text = @"Description";
    self.descriptionBodyLabel.text = [[self.selectedItem[@"description"] stringByReplacingOccurrencesOfString:@"&quot;" withString:@"'"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
    
    self.relatedTitleLabel.text = @"Related Items";
    
    [self setNeedsLayout];
    
    [self loadItemImage];
    [self loadRelatedItems];
    
    if([[AppConfig sharedConfig] isProductInCart:self.selectedItem]) {
        _addToCartButton.type = ShopBigButtonTypeItemInCart;
    } else {
        _addToCartButton.type = ShopBigButtonTypeAddToCart;        
    }
    
    CGFloat calculatedHeight = [[self class] containerHeightWithSelectedItem:self.selectedItem];
//    NSLog(@"calculatedHeight: %f", calculatedHeight);
}

- (void)didTapAddToCartButton:(id)sender {
    
    if([self.shopDelegate respondsToSelector:@selector(shopDetailScrollView:didAddProductToCart:)]) {
        [self.shopDelegate performSelector:@selector(shopDetailScrollView:didAddProductToCart:) withObject:self withObject:self.selectedItem];
    }
}

- (void)didTapGalleryButton:(id)sender {
    
    if([self.shopDelegate respondsToSelector:@selector(shopDetailScrollView:didZoomImageWithProduct:)]) {
        [self.shopDelegate performSelector:@selector(shopDetailScrollView:didZoomImageWithProduct:) withObject:self withObject:self.selectedItem];
    }
}

- (void)didTapSubtitleButton:(id)sender {
    
    if([self.shopDelegate respondsToSelector:@selector(shopDetailScrollView:didTapSubtitleButtonWithProduct:)]) {
        [self.shopDelegate performSelector:@selector(shopDetailScrollView:didTapSubtitleButtonWithProduct:) withObject:self withObject:self.selectedItem];
    }
}

- (void)didTapRequestQuoteButton:(id)sender {
    
    if([self.shopDelegate respondsToSelector:@selector(shopDetailScrollView:didTapRequestQuoteButtonWithProduct:)]) {
        [self.shopDelegate performSelector:@selector(shopDetailScrollView:didTapRequestQuoteButtonWithProduct:) withObject:self withObject:self.selectedItem];
    }
}

- (void)didTapViewRelatedButton:(id)sender {
    
    if([self.shopDelegate respondsToSelector:@selector(shopDetailScrollView:didTapViewRelatedButtonWithProduct:)]) {
        [self.shopDelegate performSelector:@selector(shopDetailScrollView:didTapViewRelatedButtonWithProduct:) withObject:self withObject:self.selectedItem];
    }
}

- (void)loadItemImage {
    
    [self.itemImageLoadingView startAnimating];
    
    NSURLRequest * itemImageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.selectedItem[@"image"]]];
    
    __block UIImageView * blockImageView = self.itemImageView;
    __block UIActivityIndicatorView * blockActivityIndicatorView = self.itemImageLoadingView;
    
    [_itemImageView setImageWithURLRequest:itemImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        blockImageView.alpha = 0.0f;
        [blockImageView setImage:image];
        
        [UIView animateWithDuration:0.75 animations:^{
            blockImageView.alpha = 1.0f;
        } completion:nil];
        
        [blockActivityIndicatorView stopAnimating];
        
        UITapGestureRecognizer * imageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGalleryButton:)];
        [blockImageView addGestureRecognizer:imageTapGestureRecognizer];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to load content for selected product. Please check your connection and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        [blockActivityIndicatorView stopAnimating];
    }];
}

- (void)loadRelatedItems {
    
    [self.relatedItems removeAllObjects];
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrieveShopItemsForCategoryWithParameters:@{ @"category": self.selectedItem[@"related"] } completion:^(NSDictionary *result) {
        
        if(result != nil && [[result allKeys] containsObject:@"items"] && [result[@"items"] isKindOfClass:[NSArray class]]) {
            
            [self.relatedItems addObjectsFromArray:result[@"items"]];
            
            // Find current item in related items and remove it
            NSDictionary * foundSelectedItem = nil;
            for(NSDictionary * item in self.relatedItems) {
                if([item[@"url"] isEqualToString:self.selectedItem[@"url"]]) {
                    foundSelectedItem = item;
                }
            }
            if(foundSelectedItem) {
                [_relatedItems removeObject:foundSelectedItem];
            }
            
            [self.relatedCollectionView reloadData];
            
            for(NSDictionary * relatedItem in self.relatedItems) {
                CGFloat heightForItem = [ShopItemCell heightForShopItem:((NSDictionary*)relatedItem)];
                
                if(heightForItem > _collectionViewHeight) {
                    _collectionViewHeight = heightForItem;
                }
            }
            
            [self setNeedsLayout];
        }
    }];
}

+ (CGFloat)containerHeightWithSelectedItem:(NSDictionary*)item {
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = applicationFrame.size.height;
    } else {
        screenWidth = applicationFrame.size.width;
    }
    
    CGSize titleTextSize = [item[@"title"] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 90.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize subtitleTextSize = [item[@"category"] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 90.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    NSString * shippingString = nil;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        shippingString = @"Shipping is $10 within Australia. Intl. shipping available on request.";
    } else {
        shippingString = @"Shipping is $10 within Australia.\nIntl. shipping available on request.";
    }
    CGSize shippingStringSize = [shippingString sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    CGSize requestQuoteTextSize = [@"Request a quote"  sizeWithFont:[UIFont systemFontOfSize:14.0f]];
    
    CGSize descriptionTitleLabelSize = [@"Description" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    NSString * cleanedDescriptionBodyString = [[item[@"description"] stringByReplacingOccurrencesOfString:@"&quot;" withString:@"'"] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
    CGSize descriptionBodyLabelSize = [cleanedDescriptionBodyString sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize relatedTitleLabelSize = [@"Related" sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    return titleTextSize.height + 8.0f + 8.0f + subtitleTextSize.height + 8.0f + 1.0f + 10.0f + kProductImageHeight + 16.0f + 8.0f + 44.0f + 8.0f + shippingStringSize.height + 8.0f + requestQuoteTextSize.height + 10.0f + 8.0f + 1.0f + 12.0f + descriptionTitleLabelSize.height + 8.0f + descriptionBodyLabelSize.height + 8.0f + 12.0f + 1.0f + relatedTitleLabelSize.height + 8.0f + kProgramCellHeight;
}

#pragma mark - UICollectionViewDataSource Methods
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
        
    ShopItemCell * cell = (ShopItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kRelatedCellReuseIdentifier forIndexPath:indexPath];
    NSDictionary * itemForCell = self.relatedItems[indexPath.row];
 
    cell.itemDict = itemForCell;
    cell.type = ShopItemCellTypeItem;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN([self.relatedItems count], 4);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kProgramCellWidth, [ShopItemCell heightForShopItem:((NSDictionary*)self.relatedItems[indexPath.row])]);
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * objectForCell = self.relatedItems[indexPath.row];
    
    if([self.shopDelegate respondsToSelector:@selector(shopDetailScrollView:didSelectRelatedProduct:)]) {
        [self.shopDelegate performSelector:@selector(shopDetailScrollView:didSelectRelatedProduct:) withObject:self withObject:objectForCell];
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
    