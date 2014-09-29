
//
//  ShopDetailTagView.m
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopDetailTagView.h"

@implementation ShopDetailTagView

- (id)initWithFrame:(CGRect)frame andName:(NSString*)name
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImage * backgroundImage = [[UIImage imageNamed:@"shop-detail-tag-bg"] stretchableImageWithLeftCapWidth:8 topCapHeight:6];
        self.tagBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        _tagBackgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        [self addSubview:self.tagBackgroundView];
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, frame.size.width, frame.size.height)];
        _tagLabel.backgroundColor = [UIColor clearColor];
        _tagLabel.text = name;
        _tagLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
        _tagLabel.shadowOffset = CGSizeMake(0, -1.0f);
        _tagLabel.font = [UIFont systemFontOfSize:13.0f];
        _tagLabel.textColor = [UIColor whiteColor];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.tagLabel];
    }
    return self;
}

+ (CGFloat)widthForName:(NSString*)name {
    
    CGSize sizeForExerciseTypeName = [name sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    return sizeForExerciseTypeName.width + 10.0f;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    _tagLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _tagBackgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    [self setNeedsDisplay];
}

@end
