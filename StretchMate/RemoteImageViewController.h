//
//  MapImageViewController.h
//  MyMonash
//
//  Created by James Eunson on 25/10/2013.
//  Copyright (c) 2013 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageOverlayInformationView.h"

// Parameters keys for initialization
#define kRemoteImageViewImageUrls @"remoteImageViewImageUrls"
#define kLocalImageViewImageUrls @"localImageViewImageUrls"

#define kLocalImageViewImageUrl @"localImageViewImageUrl"

#define kRemoteImageViewImageUrl @"remoteImageViewImageUrl"
#define kRemoteImageViewTitle @"remoteImageViewTitle"
#define kRemoteImageViewSubtitle @"remoteImageViewSubtitle"

#define kShouldShowShareButton @"shouldShowShareButton"

@interface RemoteImageViewController : UIViewController <UIScrollViewDelegate, RemoteImageOverlayInformationDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) NSMutableArray * imageViews;

@property (nonatomic, strong) UIPageControl * pageControl;

@property (nonatomic, strong) NSURL * imageUrl;
@property (nonatomic, strong) NSArray * imageUrls;

@property (nonatomic, strong) RemoteImageOverlayInformationView * informationOverlayView;

@property (nonatomic, strong) UIActivityIndicatorView * loadingIndicatorView;

@property (nonatomic, strong) NSDictionary * parameters;

- (id)initWithImageUrl:(NSURL*)imageUrl;
- (id)initWithParameters:(NSDictionary*)parameters;

@end
