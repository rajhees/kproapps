//
//  LoginMoreInformationViewController.m
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginMoreInformationViewController.h"

@interface LoginMoreInformationViewController ()

@end

@implementation LoginMoreInformationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"login-more-information" ofType:@"html"];
    NSURL * urlForPath = [NSURL fileURLWithPath:path];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:urlForPath]];
    
    self.title = @"Account FAQ";
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // Open URL in external web browser
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        if([[[request URL] absoluteString] rangeOfString:@"exersite.com.au"].location != NSNotFound) {
            
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if(self.initialAnchor) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.href = '#%@';", self.initialAnchor]];
        _initialAnchor = nil;
    }
}

@end
