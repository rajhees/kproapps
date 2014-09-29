//
//  PrescriptionEmptyView.m
//  Exersite
//
//  Created by James Eunson on 27/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionEmptyView.h"

@interface PrescriptionEmptyView ()

@property (nonatomic, assign) CGFloat storedImageHeight;
@property (nonatomic, assign) CGFloat storedImageWidth;

@end

@implementation PrescriptionEmptyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = RGBCOLOR(238, 238, 238);
        
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"prescription-empty-icon-ios7"]];
        
        _storedImageHeight = _imageView.frame.size.height;
        _storedImageWidth = _imageView.frame.size.width;
        
        [self addSubview:_imageView];
        
        // Determine correct text based on type of error message
        NSString * emptyText = @"No Prescribed Programs";
        NSString * emptySubtitle = @"You have no prescribed programs. Your practitioner must first prescribe you a program before it will appear here.";
        
        // Title label
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = emptyText;
        _titleLabel.textColor = RGBCOLOR(102, 102, 102);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        // Subtitle label
        self.subtitleLabel = [[UILabel alloc] init];
        
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.text = emptySubtitle;
        _subtitleLabel.textColor = [UIColor grayColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:14.0f];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_subtitleLabel];

        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize emptySize = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    CGSize emptySubtitleSize = [self.subtitleLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(220.0f, CGFLOAT_MAX)];
    
    CGFloat startingHeight = -1;
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        
        CGFloat imageResizeRatio = ((emptySize.height + emptySubtitleSize.height) / _storedImageHeight) * 1.5f;
        CGFloat resizedHeight = (_storedImageHeight * imageResizeRatio);
        CGFloat resizedWidth = (_storedImageWidth * imageResizeRatio);
        
        CGFloat imageStartingPoint = MIN(_titleLabel.frame.origin.x, _titleLabel.frame.origin.x) - 10 - resizedWidth;
        _imageView.frame = CGRectMake(imageStartingPoint, (self.frame.size.height / 2) - (resizedHeight / 2), resizedWidth, resizedHeight);
        
        startingHeight = (((self.frame.size.height / 2) - (_imageView.frame.size.height / 2)) - 75.0f) + _imageView.frame.size.height;
        
    } else {
        _imageView.frame = CGRectMake((self.frame.size.width / 2) - (_storedImageWidth / 2), (self.frame.size.height / 2) - (_storedImageHeight / 2), _storedImageWidth, _storedImageHeight);
        startingHeight = (((self.frame.size.height / 2) - (_imageView.frame.size.height / 2)) - 50.0f) + _imageView.frame.size.height;
    }
    
    _imageView.frame = CGRectMake((self.bounds.size.width - _imageView.frame.size.width) / 2, ((self.frame.size.height / 2) - (_imageView.frame.size.height / 2)) - 50.0f, _imageView.frame.size.width, _imageView.frame.size.height);
    
    self.titleLabel.frame = CGRectMake(8, startingHeight + 8 + 25.0f, self.bounds.size.width-16, emptySize.height);
    self.subtitleLabel.frame = CGRectMake((self.bounds.size.width - 220.0f) / 2, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 4.0f, 220.0f, emptySubtitleSize.height);
}


@end
