//
//  ProgressHUDHelper.h
//  FODMAP
//
//  Created by James Eunson on 26/06/12.
//  Copyright (c) 2012 JEON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface ProgressHUDHelper : NSObject

+ (void)showConfirmationHUDWithImage:(UIImage*)image withLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText;
+ (MBProgressHUD*)showLoadingHUDWithLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText;
+ (void)showConfirmationHUDWithImage:(UIImage*)image withLabelText:(NSString*)labelText withDetailsLabelText:(NSString*)detailsLabelText withFadeTime:(NSTimeInterval)fadeTime;

@end
