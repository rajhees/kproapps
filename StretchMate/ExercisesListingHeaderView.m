//
//  ExercisesCategoryHeaderView.m
//  Exersite
//
//  Created by James Eunson on 25/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExercisesListingHeaderView.h"
#import "Exercise.h"

@interface ExercisesListingHeaderView ()
- (UIImage*)createCategoryHeaderImageWithExercises:(NSArray*)exercises;
@end

@implementation ExercisesListingHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.headerImageView = [[UIImageView alloc] init];
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headerImageView.layer.masksToBounds = YES;
        [self addSubview:_headerImageView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        
        self.paddingView = [[UIView alloc] init];
        _paddingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
        [self addSubview:_paddingView];
        
        self.searchBarContainerView = [[UIView alloc] init];
        
        self.searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"Filter";
        _searchBar.delegate = self;
        [_searchBarContainerView addSubview:_searchBar];
        
        [self addSubview:_searchBarContainerView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _headerImageView.frame = CGRectMake(0, 44.0f, self.frame.size.width, self.frame.size.height - 44.0f);
    
    CGSize labelSize = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:24.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 10, CGFLOAT_MAX)];
    CGFloat yOffset = (self.frame.size.height - (labelSize.height + 20));
    
    _titleLabel.frame = CGRectMake(10, yOffset, self.frame.size.width - 10, labelSize.height + 20);
    _paddingView.frame = CGRectMake(0, yOffset, 10, labelSize.height + 20);
    
    id superViewForSearchBar = [_searchBar superview];
    NSString * superViewForSearchBarClassString = NSStringFromClass([superViewForSearchBar class]);
//    NSLog(@"%@", superViewForSearchBarClassString);
    
    _searchBar.frame = CGRectMake(0, 0, self.frame.size.width, 44.0f);
    _searchBarContainerView.frame = CGRectMake(0, 0, self.frame.size.width, 44.0f);
}

- (void)setExercises:(NSArray *)exercises {
    _exercises = exercises;
    self.headerImageView.image = [self createCategoryHeaderImageWithExercises:exercises];
    
    [self setNeedsLayout];
}

- (UIImage*)createCategoryHeaderImageWithExercises:(NSArray*)exercises {
    
    UIView * overviewImageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    overviewImageContainerView.backgroundColor = [UIColor whiteColor];
    overviewImageContainerView.layer.cornerRadius = 4.0f;
    overviewImageContainerView.layer.masksToBounds = YES;
    
    int i = 0, limit = 4;
    
    for(Exercise * exercise in exercises) {
        
        // Hack to remove any images that don't work well with the quadrant layout, thankfully only one so far
        if([exercise.nameBasic rangeOfString:@"Beach Walking"].location != NSNotFound) {
            continue;
        }
        
        NSArray * exerciseImages = [exercise getImages];
        UIImage * exerciseOverviewImage = [exerciseImages firstObject];
        if(!exerciseOverviewImage) {
            continue;
        }
        
        UIImageView * exerciseOverviewImageView = [[UIImageView alloc] initWithImage:exerciseOverviewImage];
        exerciseOverviewImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGFloat xOffset = 0;
        CGFloat yOffset = 0;
        
        if(i == 1) {
            xOffset = self.frame.size.width/2; yOffset = 0;
        } else if(i == 2) {
            xOffset = 0; yOffset = self.frame.size.height/2;
        } else if(i == 3) {
            xOffset = self.frame.size.width/2; yOffset = self.frame.size.height/2;
        }
        exerciseOverviewImageView.frame = CGRectMake(xOffset, yOffset, self.frame.size.width/2, self.frame.size.height/2);
        [overviewImageContainerView addSubview:exerciseOverviewImageView];
        
        if(i == (limit - 1)) break;
        
        i++;
    }
    
    UIGraphicsBeginImageContextWithOptions(overviewImageContainerView.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [overviewImageContainerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *overviewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return overviewImage;
}

- (void)reinstateSearchBar {
    
    [_searchBarContainerView addSubview:_searchBar];
    [self setNeedsLayout];
}

@end
