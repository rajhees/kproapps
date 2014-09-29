//
//  MapImageViewController.m
//  MyMonash
//
//  Created by James Eunson on 25/10/2013.
//  Copyright (c) 2013 JEON. All rights reserved.
//

#import "RemoteImageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIAlertView+Blocks.h"

@interface RemoteImageViewController ()

@property (nonatomic, strong) NSString * titleString;
@property (nonatomic, strong) NSString * subtitleString;

@property (nonatomic, strong) UIImageView * selectedImageView;

@property (nonatomic, assign) BOOL shouldShowShareButton;

- (UIImageView*)imageViewForUrl:(NSURL*)url;
- (void)pageControlPageDidChange:(id)sender;

@end

@implementation RemoteImageViewController
@synthesize informationOverlayView = _informationOverlayView;

- (id)initWithImageUrl:(NSURL*)imageUrl {
    self = [super init];
    if(self) {
        self.imageUrl = imageUrl;
    }
    return self;
}

- (id)initWithParameters:(NSDictionary*)parameters {
    self = [super init];
    if(self) {
        
        self.imageViews = [[NSMutableArray alloc] init];
        
        // Setting and image or images plural is mutually exclusive
        self.parameters = parameters;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    _loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingIndicatorView.userInteractionEnabled = NO;
    [_loadingIndicatorView startAnimating];
    
    [self.view addSubview:_loadingIndicatorView];
    
    self.scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.maximumZoomScale = 2.0f;
    _scrollView.delegate = self;
    
    if(self.imageUrls) {
        _scrollView.pagingEnabled = YES;
    }
    
    [self.view addSubview:_scrollView];
    
    if(self.imageUrls) {
        
        int i = 0;
        for(NSURL * imageUrl in self.imageUrls) {
            UIImageView * imageViewForUrl = [self imageViewForUrl:imageUrl];
            
            [self.scrollView addSubview:imageViewForUrl];
            [self.imageViews addObject:imageViewForUrl];
            
            if(i == 0) {
                self.selectedImageView = imageViewForUrl;
            }
            
            i++;
        }
        
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width * [self.imageViews count], self.view.frame.size.height);
        
        self.pageControl = [[UIPageControl alloc] init];
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [_pageControl addTarget:self action:@selector(pageControlPageDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.pageControl];
        
    } else {
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        
        self.imageView = [self imageViewForUrl:self.imageUrl];
        [self.scrollView addSubview:_imageView];
    }
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalViewControllerAnimated:)];
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    
    NSDictionary * bindings = nil;
    
    if(self.titleString && self.subtitleString) {
        
        self.informationOverlayView = [[RemoteImageOverlayInformationView alloc] initWithFrame:CGRectZero];
        
        _informationOverlayView.titleLabel.text = self.titleString;
        _informationOverlayView.subtitleLabel.text = self.subtitleString;
        _informationOverlayView.overlayDelegate = self;
        
        if(!self.shouldShowShareButton) {
            _informationOverlayView.shareButton.hidden = YES;
        }
        
        _informationOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:self.informationOverlayView];
        
        bindings = NSDictionaryOfVariableBindings(_loadingIndicatorView, _informationOverlayView);
        
    } else {
        bindings = NSDictionaryOfVariableBindings(_loadingIndicatorView);
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_loadingIndicatorView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_loadingIndicatorView]|" options:0 metrics:nil views:bindings]];
    
    if(self.titleString && self.subtitleString) {
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_informationOverlayView]|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_informationOverlayView]|" options:0 metrics:nil views:bindings]];
    }
    
    if(self.imageUrls) {
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pageControl]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl)]];
        
        if(self.titleString && self.subtitleString) {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl(30)]-10-[_informationOverlayView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl, _informationOverlayView)]];
        } else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_pageControl(30)]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_pageControl, _informationOverlayView)]];
        }
    }
    
    [self.view bringSubviewToFront:_loadingIndicatorView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Not sure why this is necessary, but it is apparently
    CGRect viewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        viewFrame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    }
    
    self.scrollView.frame = viewFrame;
    
    if(self.imageUrls) {
        
//        NSLog(@"setting _scrollView.contentSize to CGSizeMake(%f, %f)", viewFrame.size.width * [self.imageViews count], viewFrame.size.height);
        _scrollView.contentSize = CGSizeMake(viewFrame.size.width * [self.imageViews count], viewFrame.size.height);
        
        int i = 0;
        for(UIImageView * imageView in self.imageViews) {
            imageView.frame = CGRectMake((viewFrame.size.width * i), 0, viewFrame.size.width, viewFrame.size.height);
            i++;
        }
        
    } else {
        _scrollView.contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height);
    }
    
    [_informationOverlayView setNeedsLayout];
    [_informationOverlayView invalidateIntrinsicContentSize];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.view setNeedsLayout];
}

#pragma mark - Property Override
- (void)setParameters:(NSDictionary *)parameters {
    _parameters = parameters;
    
    if([[parameters allKeys] containsObject:kRemoteImageViewImageUrls]) {
        self.imageUrls = parameters[kRemoteImageViewImageUrls];
        
    } else if([[parameters allKeys] containsObject:kLocalImageViewImageUrls]) {
        self.imageUrls = parameters[kLocalImageViewImageUrls];
        
    } else if([[parameters allKeys] containsObject:kRemoteImageViewImageUrl]) {
        self.imageUrl = parameters[kRemoteImageViewImageUrl];
    }
    
    if([[parameters allKeys] containsObject:kRemoteImageViewTitle]) {
        self.titleString = parameters[kRemoteImageViewTitle];
    }
    if([[parameters allKeys] containsObject:kRemoteImageViewSubtitle]) {
        self.subtitleString = parameters[kRemoteImageViewSubtitle];
    }
    if([[parameters allKeys] containsObject:kShouldShowShareButton]) {
        self.shouldShowShareButton = [parameters[kShouldShowShareButton] boolValue];
    }
}

- (void)setShouldShowShareButton:(BOOL)shouldShowShareButton {
    _shouldShowShareButton = shouldShowShareButton;
    
    _informationOverlayView.shareButton.hidden = !shouldShowShareButton;
}

#pragma mark - Private Methods
- (UIImageView*)imageViewForUrl:(NSURL *)url {
    
    UIImageView * imageView = [[UIImageView alloc] init];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = NO;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if([[self.parameters allKeys] containsObject:kRemoteImageViewImageUrl]) {
        
        NSURLRequest * requestForImage = [NSURLRequest requestWithURL:url];
        
        __block UIImageView * blockImageView = imageView;
        __block UIActivityIndicatorView * blockLoadingIndicatorView = _loadingIndicatorView;
        
        [imageView setImageWithURLRequest:requestForImage placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            if((self.imageUrls && [self.imageViews count] == 0) || self.imageUrl) {
                [UIView animateWithDuration:0.3 animations:^{
                    blockLoadingIndicatorView.alpha = 0;
                } completion:^(BOOL finished) {
                    if(finished) {
                        [blockLoadingIndicatorView stopAnimating];
                        [blockLoadingIndicatorView removeFromSuperview];
                    }
                }];
            }
            
            blockImageView.image = image;
            [self.view setNeedsLayout];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to load image. Please check your connection and try again." cancelButtonItem:[RIButtonItem itemWithLabel:@"OK"] otherButtonItems: nil];
            [alertView show];
        }];
        
    } else if([[self.parameters allKeys] containsObject:kLocalImageViewImageUrl]) {
        
        NSURL * localImageFilePathURL = _parameters[kLocalImageViewImageUrl];
        [imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:localImageFilePathURL]]];
        
        [_loadingIndicatorView stopAnimating];
    }
    
    return imageView;
}

#pragma mark - UIScrollViewDelegate Methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if(self.imageUrls) {
        return _selectedImageView;
    } else {
        return _imageView;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger pageNumber = scrollView.contentOffset.x / self.view.frame.size.width;
    self.selectedImageView = self.imageViews[pageNumber];
}

#pragma mark - RemoteImageOverlayInformationDelegate
- (void)overlayInformationView:(RemoteImageOverlayInformationView*)overlayInformationView didTapShareButton:(UIButton*)shareButton {
    
    NSString * concatTitleSubtitleString = [NSString stringWithFormat:@"%@ - %@", self.titleString, self.subtitleString];
    
    NSArray *activityItems = nil;
    if(self.imageUrls) {
        
        UIImageView * firstImageView = [self.imageViews firstObject];
        activityItems = @[concatTitleSubtitleString, firstImageView.image];
        
    } else {
        activityItems = @[concatTitleSubtitleString, self.imageView.image];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - UIPageControl Methods
- (void)pageControlPageDidChange:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * _pageControl.currentPage, 0) animated:YES];
}

@end
