//
//  ExercisesCategoryHeaderView.h
//  Exersite
//
//  Created by James Eunson on 25/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExercisesListingHeaderView : UIView <UISearchBarDelegate>

@property (nonatomic, strong) UIImageView * headerImageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIView * paddingView;

@property (nonatomic, strong) NSArray * exercises;

@property (nonatomic, strong) UISearchBar * searchBar;

// Necessitated because UISearchDisplayController changes frame of search bar
// to match superview, which is definitely NOT what we want
@property (nonatomic, strong) UIView * searchBarContainerView;

- (void)reinstateSearchBar;

@end
