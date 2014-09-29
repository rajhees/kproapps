//
//  ExerciseGalleryView.m
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExerciseGalleryView.h"
#import "ExerciseBlueButton.h"
#import "UIImageView+AFNetworking.h"

#define kGalleryImageWidth 258
#define kGalleryImageHeight 151

@interface ExerciseGalleryView()
- (void)didTapGalleryButton:(id)sender;
- (void)didTapGalleryImage:(id)sender;

@end

@implementation ExerciseGalleryView

- (id)initWithFrame:(CGRect)frame options:(NSDictionary*)options
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.galleryViewController = [[FGController alloc] initWithDelegate:self];
        
        // Picture Frame and Description
        if(options[@"images"]) {
            self.galleryImages = options[@"images"];
            
        } else if(options[@"videos"]) {
            self.galleryVideos = options[@"videos"];
        }
        
        UIView * exerciseImageInnerContainerView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, kGalleryImageWidth + 16, kGalleryImageHeight + 16)];
        UIView * exerciseImageOuterContainerView = [[UIView alloc] initWithFrame:CGRectMake(13, 0, kGalleryImageWidth + 18, kGalleryImageHeight + 18)];
        
        self.galleryScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(8, 8, kGalleryImageWidth, kGalleryImageHeight)];
        _galleryScrollView.pagingEnabled = YES;
        _galleryScrollView.contentSize = CGSizeMake(kGalleryImageWidth * [self.galleryImages count], kGalleryImageHeight);
        _galleryScrollView.showsHorizontalScrollIndicator = NO;
        _galleryScrollView.backgroundColor = RGBCOLOR(225, 225, 225);
        _galleryScrollView.delegate = self;
        
        exerciseImageInnerContainerView.layer.borderColor = [[UIColor whiteColor] CGColor];
        exerciseImageInnerContainerView.layer.borderWidth = 8.0f;
        
        exerciseImageOuterContainerView.layer.borderColor = [RGBCOLOR(170, 170, 170) CGColor];
        exerciseImageOuterContainerView.layer.borderWidth = 1.0f;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
         
            exerciseImageOuterContainerView.layer.shadowColor = [[UIColor whiteColor] CGColor];
            exerciseImageOuterContainerView.layer.shadowOffset = CGSizeMake(0, 1.0f);
            exerciseImageOuterContainerView.layer.shadowOpacity = 1.0f;
            exerciseImageOuterContainerView.layer.shadowRadius = 0.0f;
        }
        
        if(self.galleryImages) {
            
            NSMutableArray * mutableGalleryImageViews = [NSMutableArray array];
            for(int i = 0; i < [self.galleryImages count]; i++) {
                
                id imageObject = self.galleryImages[i];
                UIImageView * addedImageView = [[UIImageView alloc] init];                
                
                if([imageObject isKindOfClass:[UIImage class]]) {
                    addedImageView.image = ((UIImage*)imageObject);
                } else if([imageObject isKindOfClass:[NSURL class]]) {
                    
                    NSURL * imageObjectURL = (NSURL*)imageObject;
                    __block UIImageView * blockAddedImageView = addedImageView;
                    
                    [addedImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageObjectURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        
                        blockAddedImageView.image = image;
                        
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                        NSLog(@"Unable to load image at url: %@, %@", imageObjectURL, [error localizedDescription]);
                    }];
                }
                

                addedImageView.frame = CGRectMake(kGalleryImageWidth * i, 0, kGalleryImageWidth, kGalleryImageHeight);
                addedImageView.contentMode = UIViewContentModeScaleAspectFill;
                
                UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGalleryImage:)];
                [addedImageView addGestureRecognizer:tapGestureRecognizer];
                
                [self.galleryScrollView addSubview:addedImageView];
                [mutableGalleryImageViews addObject:addedImageView];
            }
            self.galleryImageViews = [NSArray arrayWithArray:mutableGalleryImageViews];
            
        } else {
            
            NSString * videoFilePath = [self.galleryVideos firstObject];
            
            if(videoFilePath) {

                NSURL * videoFilePathUrl = [NSURL fileURLWithPath:videoFilePath];

                self.playerController = [[MPMoviePlayerController alloc] initWithContentURL: videoFilePathUrl];
                
                [_playerController prepareToPlay];
                [_playerController setScalingMode:MPMovieScalingModeAspectFit];
                _playerController.controlStyle = MPMovieControlStyleDefault;
                _playerController.fullscreen = NO;
                _playerController.shouldAutoplay = NO;
                
                [_playerController.view setFrame: CGRectMake(0, 0, kGalleryImageWidth, kGalleryImageHeight)];
                
                [self.galleryScrollView addSubview: _playerController.view];
                [self.galleryScrollView bringSubviewToFront:_playerController.view];
            }
        }
        
        [exerciseImageInnerContainerView addSubview:self.galleryScrollView];
        [exerciseImageOuterContainerView addSubview:exerciseImageInnerContainerView];
        
        [self addSubview:exerciseImageOuterContainerView];
        
        if(self.galleryImages) {
            ExerciseBlueButton * zoomButton = [[ExerciseBlueButton alloc] initWithFrame:CGRectMake(exerciseImageOuterContainerView.frame.size.width-12-44, exerciseImageOuterContainerView.frame.size.height-12 - 44, 44, 44) type:ExerciseBlueButtonTypeZoom];
            [zoomButton addTarget:self action:@selector(didTapGalleryButton:) forControlEvents:UIControlEventTouchUpInside];
            [exerciseImageOuterContainerView addSubview:zoomButton];
        }
        
        // Displays description container and label by default or if specified, hides if not specified or specified as false
//        if(!options || [[options allKeys] indexOfObject:@"showDescription"] == NSNotFound || [options[@"showDescription"] boolValue]) {
//            
//            UIImageView * exerciseTabView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-tab-bg"]];
//            CGFloat exerciseTabYOffset = exerciseImageOuterContainerView.frame.origin.y + exerciseImageOuterContainerView.frame.size.height - 1.0f;
//            exerciseTabView.frame = CGRectMake(13, exerciseTabYOffset, exerciseTabView.frame.size.width, exerciseTabView.frame.size.height);
//            [self addSubview:exerciseTabView];
//            
//            UILabel * descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 2, exerciseTabView.frame.size.width-14, exerciseTabView.frame.size.height-8)];
//            descriptionLabel.backgroundColor = [UIColor clearColor];
//            descriptionLabel.textColor = RGBCOLOR(65, 65, 65);
//            descriptionLabel.font = [UIFont systemFontOfSize:11.0f];
//            descriptionLabel.shadowColor = RGBCOLOR(255, 255, 255);
//            descriptionLabel.shadowOffset = CGSizeMake(0, -1.0f);
//            descriptionLabel.numberOfLines = 0;
//            descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            
//            descriptionLabel.text = @"Description for image could go here over two lines filling up available space";
//            [exerciseTabView addSubview:descriptionLabel];
//        }
        
        CGFloat pageControlYOffset = exerciseImageOuterContainerView.frame.origin.y + exerciseImageOuterContainerView.frame.size.height - 29;
        self.galleryPageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(22+50, pageControlYOffset, kGalleryImageWidth-100, 20)];
        _galleryPageControl.pageControlStyle = PageControlStyleThumb;
        _galleryPageControl.gapWidth = 12;
        _galleryPageControl.thumbImage = [UIImage imageNamed:@"exercise-page-control"];
        _galleryPageControl.selectedThumbImage = [UIImage imageNamed:@"exercise-page-control-selected"];
        _galleryPageControl.backgroundColor = [UIColor clearColor];
        _galleryPageControl.numberOfPages = self.galleryImages.count;
        [_galleryPageControl addTarget:self action:@selector(pageControlPageDidChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.galleryPageControl];	
    }
    return self;
}

#pragma mark - PageControlDelegate Methods
- (void)pageControlPageDidChange:(StyledPageControl *)pageControl {
    [self.galleryScrollView setContentOffset:CGPointMake((self.galleryPageControl.currentPage * kGalleryImageWidth), 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView_ {
    int pageNumber = (scrollView_.contentOffset.x / kGalleryImageWidth);
    self.galleryPageControl.currentPage = pageNumber;
}

#pragma mark - FGControllerDelegate Methods
- (BOOL)canRotateToInterfaceOrientation:(UIInterfaceOrientation) orientation {
    return YES;
}

#pragma mark - Private Methods
- (void)didTapGalleryButton:(id)sender {
    
    if(self.galleryImageViews.count > 0) {
        UIImageView * selectedImageView = self.galleryImageViews[self.galleryPageControl.currentPage];
        if([self.delegate respondsToSelector:@selector(exerciseGalleryView:didTapZoomButtonWithImage:)]) {
            [self.delegate performSelector:@selector(exerciseGalleryView:didTapZoomButtonWithImage:) withObject:self withObject:selectedImageView.image];
        }
    }
}

- (void)didTapGalleryImage:(id)sender {
    
    UIImageView * imageView = (UIImageView*)sender;
    if([self.delegate respondsToSelector:@selector(exerciseGalleryView:didTapZoomButtonWithImage:)]) {
        [self.delegate performSelector:@selector(exerciseGalleryView:didTapZoomButtonWithImage:) withObject:self withObject:imageView.image];
    }
}

@end
