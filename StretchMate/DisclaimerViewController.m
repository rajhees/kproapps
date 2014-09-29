//
//  DisclaimerViewController.m
//  Exersite
//
//  Created by James Eunson on 8/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "TutorialPageViewController.h"

@interface DisclaimerViewController ()

- (void)didTapAcceptButton:(id)sender;
- (void)doneAction:(id)sender;

@end

@implementation DisclaimerViewController

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
    
    self.type = DisclaimerViewControllerTypeSettings;
    
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
    
    self.title = @"Disclaimer";
    
    if(self.type == DisclaimerViewControllerTypeInitial) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Accept" style:UIBarButtonItemStylePlain target:self action:@selector(didTapAcceptButton:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[_webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - Private Methods
- (void)didTapAcceptButton:(id)sender {
    
    TutorialPageViewController * controller = [[TutorialPageViewController alloc] init];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
