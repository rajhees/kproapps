//
//  ProgressHUDHelper.m
//  FODMAP
//
//  Created by James Eunson on 26/06/12.
//  Copyright (c) 2012 JEON. All rights reserved.
//

#import "ProgressHUDHelper.h"

@implementation ProgressHUDHelper

static NSTimeInterval kHudHideDelay = 2.0f;

+ (void)showConfirmationHUDWithImage:(UIImage*)image withLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText withFadeTime:(NSTimeInterval)fadeTime {
    
    UIView * targetView = [[UIApplication sharedApplication] keyWindow];
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:targetView];
    hud.customView = [[UIImageView alloc] initWithImage:image];
	hud.mode = MBProgressHUDModeCustomView;
    [targetView addSubview:hud];
    
    hud.labelText = labelText;
    hud.detailsLabelText = detailsLabelText;
    
    hud.userInteractionEnabled = NO;
    
    [hud show:YES];
    [hud hide:YES afterDelay:fadeTime];
}

+ (void)showConfirmationHUDWithImage:(UIImage*)image withLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText {
    [[self class] showConfirmationHUDWithImage:image withLabelText:labelText withDetailsLabelText:detailsLabelText withFadeTime:kHudHideDelay];
}

+ (MBProgressHUD*)showLoadingHUDWithLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText {
    
    UIView * targetView = [[UIApplication sharedApplication] keyWindow];
    
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:targetView];
	hud.mode = MBProgressHUDModeIndeterminate;
    [targetView addSubview:hud];
    
    hud.labelText = labelText;
    hud.detailsLabelText = detailsLabelText;

    hud.userInteractionEnabled = NO;    
    
    [hud show:YES];
    return hud;
}


@end
