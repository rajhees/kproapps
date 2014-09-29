//
//  TutorialViewController.m
//  Exersite
//
//  Created by James Eunson on 6/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "TutorialViewController.h"

#define kTutorialContentTitleKey @"title"
#define kTutorialContentDescriptionKey @"description"
#define kTutorialContentImageKey @"image"

@interface TutorialViewController ()

@property (nonatomic, assign) CGFloat startingImageHeight;
@property (nonatomic, assign) CGFloat startingImageWidth;

@end

@implementation TutorialViewController

- (id)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if(self) {
        self.contentDictionary = dictionary;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = RGBCOLOR(51, 51, 51);
    _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = _contentDictionary[kTutorialContentTitleKey];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.alpha = 0.0f;
    [self.view addSubview:_titleLabel];
    
    self.descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.textColor = RGBCOLOR(128, 128, 128);
    _descriptionLabel.font = [UIFont systemFontOfSize:14.0f];
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _descriptionLabel.textAlignment = NSTextAlignmentCenter;
    _descriptionLabel.text = _contentDictionary[kTutorialContentDescriptionKey];
    _descriptionLabel.alpha = 0.0f;
    [self.view addSubview:_descriptionLabel];
    
    self.pageImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_contentDictionary[kTutorialContentImageKey]]];
    _pageImageView.alpha = 0.0f;
    
    if(self.view.frame.size.height == 480.0f) {
        
        self.startingImageWidth = _pageImageView.frame.size.width;
        self.startingImageHeight = _pageImageView.frame.size.height;
        
        _pageImageView.frame = CGRectMake(0, 0, _startingImageWidth * 0.8f, _startingImageHeight * 0.8f);
    }
    
    [self.view addSubview:_pageImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_pageImageView.alpha != 1.0f) {
        [UIView animateWithDuration:0.5 animations:^{
            _pageImageView.alpha = 1.0f;
        }];
        
        [UIView animateWithDuration:0.5 delay:0.1 options:0 animations:^{
            _titleLabel.alpha = 1.0f;
        } completion:nil];
        
        [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
            _descriptionLabel.alpha = 1.0f;
        } completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat textImageGap = 20.0f;
    
    // CGSizeMake(self.view.frame.size.width - 32.0f, CGFLOAT_MAX)
    CGSize sizeForTitleLabel = [_titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    CGSize sizeForDescriptionLabel = [_descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 32.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat startingPoint = (self.view.frame.size.height / 2) - ((_pageImageView.frame.size.height + textImageGap + sizeForTitleLabel.height + 4.0f +sizeForDescriptionLabel.height) / 2);
    
    self.pageImageView.frame = CGRectMake((self.view.frame.size.width / 2) - (_pageImageView.frame.size.width / 2), startingPoint, _pageImageView.frame.size.width, _pageImageView.frame.size.height);
    
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width / 2) - (sizeForTitleLabel.width / 2), _pageImageView.frame.origin.y + _pageImageView.frame.size.height + textImageGap, sizeForTitleLabel.width, sizeForTitleLabel.height);
    self.descriptionLabel.frame = CGRectMake((self.view.frame.size.width / 2) - (sizeForDescriptionLabel.width / 2), _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 4.0f, sizeForDescriptionLabel.width, sizeForDescriptionLabel.height);
}

@end
