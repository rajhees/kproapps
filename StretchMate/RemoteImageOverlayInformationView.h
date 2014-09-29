//
//  RemoteImageOverlayInformationView.h
//  MyMonash
//
//  Created by James Eunson on 25/10/2013.
//  Copyright (c) 2013 JEON. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RemoteImageOverlayInformationDelegate;
@interface RemoteImageOverlayInformationView : UIToolbar

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;

@property (nonatomic, strong) UIImageView * iconImageView;

@property (nonatomic, strong) UIButton * shareButton;

@property (nonatomic, assign) __unsafe_unretained id<RemoteImageOverlayInformationDelegate> overlayDelegate;

@end

@protocol RemoteImageOverlayInformationDelegate <NSObject>
- (void)overlayInformationView:(RemoteImageOverlayInformationView*)overlayInformationView didTapShareButton:(UIButton*)shareButton;
@end