//
//  ShopCategoryToolbar.m
//  Exersite
//
//  Created by James Eunson on 21/10/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopCategoryToolbar.h"

#define kShopSearchButtonIconSize 24.0f

@interface ShopCategoryToolbar ()

- (void)didTapSearchButton:(id)sender;
- (void)didTapCategoryButton:(id)sender;
- (void)_clearSelectedButton;

//@property (nonatomic, assign) NSInteger lastContentOffset;

@end

@implementation ShopCategoryToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.translucent = NO;
        self.barTintColor = [UIColor whiteColor];
        
        self.buttons = [[NSMutableArray alloc] init];
        self.selectedButtonIndex = 0;
        
        self.searchButton = [[UIButton alloc] init];
        [_searchButton setImage:[UIImage imageNamed:@"shop-search-button-icon-ios7"] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(didTapSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_searchButton];
        
        self.separatorBorderLayer = [CALayer layer];
        [_separatorBorderLayer setBackgroundColor:RGBCOLOR(204, 204, 204).CGColor];
        [self.layer addSublayer:_separatorBorderLayer];
        
        self.bottomBorderLayer = [CALayer layer];
        [_bottomBorderLayer setBackgroundColor:RGBCOLOR(204, 204, 204).CGColor];
        [self.layer addSublayer:_bottomBorderLayer];
        
        self.scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.searchButton.frame = CGRectMake(10, 10, kShopSearchButtonIconSize, kShopSearchButtonIconSize);
    
    _separatorBorderLayer.frame = CGRectMake(_searchButton.frame.origin.x + _searchButton.frame.size.width + 10, 6, 1, self.frame.size.height - 12.0f);
    _bottomBorderLayer.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    
    _scrollView.frame = CGRectMake(_separatorBorderLayer.frame.origin.x + 1.0f + 10, 6, self.frame.size.width - 44.0f - 10.0f, self.frame.size.height - 12.0f);
//    _scrollView.contentSize = CGSizeMake((self.frame.size.width - 44.0f - 10.0f) * 2, self.frame.size.height - 12.0f);
    
    CGFloat contentSizeAccumulator = 0;
    for(ShopCategoryToolbarButton * button in self.buttons) {
        contentSizeAccumulator += (button.intrinsicContentSize.width + 10.0f);
    }
//    contentSizeAccumulator += ((ShopCategoryToolbarButton *)[self.buttons lastObject]).intrinsicContentSize.width + 10.0f;
    contentSizeAccumulator += self.scrollView.frame.size.width;
    
    self.scrollView.contentSize = CGSizeMake(contentSizeAccumulator, self.frame.size.height - 12.0f);
}

- (void)addButton:(ShopCategoryToolbarButton*)button {
    
    [self.buttons addObject:button];
    [self.scrollView addSubview:button];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    if([self.buttons count] == 1) { // First button
        [button setSelected:YES];
    }
    
    [button addTarget:self action:@selector(didTapCategoryButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Generic vertical position constraint is constant
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    
    // Create constraint linking previous and current button in layout constraint
    if([self.buttons count] == 1) { // First button
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[button]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
        
    } else {
        
        NSInteger previousButtonIndex = [self.buttons indexOfObject:button] - 1;
        ShopCategoryToolbarButton * previousButton = self.buttons[previousButtonIndex];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousButton]-10-[button]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button, previousButton)]];
    }
    
    [self setNeedsLayout];
}

- (void)clearState {
    
    [self _clearSelectedButton];
    self.selectedButtonIndex = 0;
    
    [self.buttons removeAllObjects];
    for(UIView * subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    [self removeConstraints:self.constraints];
    [self setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    [self _clearSelectedButton];
    
    NSInteger newSelectedButtonIndex = -1; // TODO: BOUNDS CHECK
    
    // If target position falls within a particular button's bounds
    int i = 0;
    for(ShopCategoryToolbarButton * button in self.buttons) {
        
        float startingBounds = 0;
        float endingBounds = 0;
        
        // Hot areas for each button include half of the previous button and half of the current
        // this allows you to skip to the next button by dragging over the half-way point, and backwards likewise
        
        if(i == 0) {
            endingBounds = ((button.frame.size.width + 10.0f) / 2);
            
        } else if(i > 0 && i < ([self.buttons count] - 1)) {
            
            ShopCategoryToolbarButton * previousButton = self.buttons[i-1];
            
            startingBounds = button.frame.origin.x - ((previousButton.frame.size.width + 10.0f) / 2);
            endingBounds = button.frame.origin.x + ((button.frame.size.width + 10.0f) / 2);
            
        } else if(i == ([self.buttons count] - 1)) {
            
            // Final button bounds lasts from start of final button to end of scrollview contentSize.width
            // which intuitively makes sense, because a fling to the end, should stay at the end, otherwise
            // it reverts to the start
            
            ShopCategoryToolbarButton * previousButton = self.buttons[i-1];
            startingBounds = button.frame.origin.x - ((previousButton.frame.size.width + 10.0f) / 2);
            endingBounds = self.scrollView.contentSize.width;
        }
        
        if((*targetContentOffset).x >= startingBounds && (*targetContentOffset).x <= endingBounds) {
            newSelectedButtonIndex = i;
            break;
        }
        i++;
    }
    
    if(newSelectedButtonIndex == -1) {
        newSelectedButtonIndex = 0;
    }
    
    [self selectButtonAtIndex:0 shouldNotifyDelegate:YES animated:YES];
    
//    ShopCategoryToolbarButton * selectedButton = self.buttons[newSelectedButtonIndex];
//    [selectedButton setSelected:YES];
//    (*targetContentOffset).x = selectedButton.frame.origin.x;
//    self.selectedButtonIndex = newSelectedButtonIndex;
    
//    if([self.categoryToolbarDelegate respondsToSelector:@selector(shopCategoryToolbar:didChangeToCategoryAtIndex:)]) {
//        [self.categoryToolbarDelegate performSelector:@selector(shopCategoryToolbar:didChangeToCategoryAtIndex:) withObject:self withObject:@(self.selectedButtonIndex)];
//    }
    
//    NSLog(@"target x: %f, current x: %f", (*targetContentOffset).x, scrollView.contentOffset.x);
}

#pragma mark - Private Methods
- (void)didTapCategoryButton:(id)sender {
    
//    NSLog(@"didTapCategoryButton:");
    
    ShopCategoryToolbarButton * button = (ShopCategoryToolbarButton*)sender;
    [self selectButtonAtIndex:[self.buttons indexOfObject:button] shouldNotifyDelegate:YES animated:YES];
    
//    if([self.categoryToolbarDelegate respondsToSelector:@selector(shopCategoryToolbar:didChangeToCategoryAtIndex:)]) {
//        [self.categoryToolbarDelegate performSelector:@selector(shopCategoryToolbar:didChangeToCategoryAtIndex:) withObject:self withObject:@(indexOfButton)];
//    }
//    
//    [self _clearSelectedButton];
//    
//    [button setSelected:YES];
//    [self.scrollView setContentOffset:CGPointMake(button.frame.origin.x, 0) animated:YES];
}

- (void)selectButtonAtIndex:(NSInteger)index shouldNotifyDelegate:(BOOL)shouldNotifyDelegate animated:(BOOL)animated {
    
    ShopCategoryToolbarButton * button = self.buttons[index];
    
    if(shouldNotifyDelegate) {
        if([self.categoryToolbarDelegate respondsToSelector:@selector(shopCategoryToolbar:didChangeToCategoryAtIndex:)]) {
            [self.categoryToolbarDelegate performSelector:@selector(shopCategoryToolbar:didChangeToCategoryAtIndex:) withObject:self withObject:@(index)];
        }
    }
    
    [self _clearSelectedButton];
    
    [button setSelected:YES];
    [self.scrollView setContentOffset:CGPointMake(button.frame.origin.x, 0) animated:animated];
}


- (void)didTapSearchButton:(id)sender {
//    NSLog(@"didTapSearchButton:");
    
    if([self.categoryToolbarDelegate respondsToSelector:@selector(shopCategoryToolbar:didTapSearchButton:)]) {
        [self.categoryToolbarDelegate performSelector:@selector(shopCategoryToolbar:didTapSearchButton:) withObject:self withObject:sender];
    }
}

- (void)_clearSelectedButton {
    
    NSArray * filteredButtons = [self.buttons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
    [[filteredButtons firstObject] setSelected:NO];
}

@end
