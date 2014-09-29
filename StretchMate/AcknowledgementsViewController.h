//
//  AcknowledgementsViewController.h
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcknowledgementsViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIWebView * webView;

- (id)initWithFile:(NSString*)htmlFileName key:(NSString*)key;

@end
