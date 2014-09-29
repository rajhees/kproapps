//
//  DisclaimerViewController.h
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DisclaimerViewControllerTypeInitial, // Displayed on first load of the app
    DisclaimerViewControllerTypeSettings // Displayed when the user selects the controller from settings
} DisclaimerViewControllerType;

@interface DisclaimerViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIWebView * webView;

@property (nonatomic, assign) DisclaimerViewControllerType type;

- (id)initWithFile:(NSString*)htmlFileName key:(NSString*)key;

@end
