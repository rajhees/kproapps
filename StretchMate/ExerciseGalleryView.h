//
//  ExerciseGalleryView.h
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"

@protocol ExerciseGalleryViewDelegate;
@interface ExerciseGalleryView : UIView <UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame options:(NSDictionary*)options;

@property (nonatomic, strong) UIScrollView * galleryScrollView;
@property (nonatomic, strong) StyledPageControl * galleryPageControl;
@property (nonatomic, strong) NSArray * galleryImageViews;

@property (nonatomic, strong) NSArray * galleryImages;
@property (nonatomic, strong) NSArray * galleryVideos;

@property (nonatomic, strong) MPMoviePlayerController * playerController;

@property (nonatomic, assign) __unsafe_unretained id<ExerciseGalleryViewDelegate> delegate;

@end

@protocol ExerciseGalleryViewDelegate<NSObject>
@optional
- (void)exerciseGalleryView:(ExerciseGalleryView*)galleryView didTapZoomButtonWithImage:(UIImage*)image;
@end

