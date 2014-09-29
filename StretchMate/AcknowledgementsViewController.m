//
//  AcknowledgementsViewController.m
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "AcknowledgementsViewController.h"

@interface AcknowledgementsViewController ()

@end

@implementation AcknowledgementsViewController

- (id)initWithFile:(NSString*)urlString key:(NSString*)key {
	if (!(self = [super initWithNibName:nil bundle:nil])) {
		return nil;
	}
    
    self.url = [NSURL URLWithString:urlString];
    
	if (!self.url || ![self.url scheme]) {
		NSString *path = [[NSBundle mainBundle] pathForResource:[urlString stringByDeletingPathExtension] ofType:[urlString pathExtension]];
		if(path)
			self.url = [NSURL fileURLWithPath:path];
		else
			self.url = nil;
	}
	return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] init];
    [self.webView setDelegate:self];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:[self webView]];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_webView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Acknowledgements";
}

- (void)viewWillAppear:(BOOL)animated {
	[_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

@end
