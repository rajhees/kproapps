//
//  ShelfView.m
//  StretchMate
//
//  Created by James Eunson on 4/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopShelfView.h"

@implementation ShopShelfView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView * shelfView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-shelf"]];
        shelfView.frame = CGRectMake(0, 0, shelfView.frame.size.width, shelfView.frame.size.height);
        [self addSubview:shelfView];
    }
    return self;
}

+ (CGSize)sizeForShelfView {
    
    UIImageView * shelfView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-shelf"]];
    return shelfView.frame.size;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
