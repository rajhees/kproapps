//
//  ShopFlowLayout.m
//  StretchMate
//
//  Created by James Eunson on 4/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopFlowLayout.h"
#import "ShopShelfView.h"
#import "ShopItemCell.h"

#define kShelfDecorationViewKind @"ShopShelfView"

#define kTopMargin 10
#define kSectionHeaderHeight 28
#define kVerticalPadding 35

@interface ShopFlowLayout()

@property (nonatomic, strong) NSMutableDictionary * sectionSizeLookup;

@end

@implementation ShopFlowLayout

- (id)init {
    self = [super init];
    if(self) {
        
        [self registerClass:[ShopShelfView class] forDecorationViewOfKind:kShelfDecorationViewKind];
        self.sectionSizeLookup = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray * mutableLayoutAttributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    // Serves to reset the margin of the section header to 0, to counteract effects by the insets delegate method
    BOOL decorationViewAttributesFound = NO;
    NSMutableArray * sectionsForRect = [[NSMutableArray alloc] init];
    
    for(UICollectionViewLayoutAttributes * attributes in mutableLayoutAttributes) {
        
        if(attributes.representedElementCategory == UICollectionElementCategorySupplementaryView) {
            if(attributes.frame.origin.x > 0) {
                [attributes setFrame:CGRectMake(0, attributes.frame.origin.y, attributes.frame.size.width, attributes.frame.size.height)];
            }
        } else if(attributes.representedElementCategory == UICollectionElementCategoryDecorationView) {
            decorationViewAttributesFound = YES;   
        } else if(attributes.representedElementCategory == UICollectionElementCategoryCell) {
            attributes.zIndex = 50; // Ensure cells are above shelves
        }
        if(![sectionsForRect containsObject:@(attributes.indexPath.section)]) {
            [sectionsForRect addObject:@(attributes.indexPath.section)];
        }
    }
    
    if(!decorationViewAttributesFound) {
        
        CGFloat sectionSize = 0;
        
//        for(NSNumber * sectionIndex in sectionsForRect) {
        
//            NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:[sectionIndex integerValue]]; // Given that there is only one section, 0 is hardcoded
            NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0]; // Given that there is only one section, 0 is hardcoded
            
            NSInteger numberOfShelves = 0;
            if(numberOfItems > 0) {
                numberOfShelves = MAX(1, (NSInteger)ceilf(numberOfItems/2.0f));
            }
            
//            NSLog(@"numberOfShelves for section: %d = %d", [sectionIndex integerValue], numberOfShelves);
        
            for(int i = 0; i < numberOfShelves; i++) {
                
//                NSIndexPath *decorationIndexPath = [NSIndexPath indexPathForItem:i inSection:[sectionIndex integerValue]];
                NSIndexPath *decorationIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
                UICollectionViewLayoutAttributes *decorationAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kShelfDecorationViewKind withIndexPath:decorationIndexPath];
                
//                CGFloat shelfYOffset = (i*(kProgramCellHeight + kProgramCellMarginBottom + kVerticalPadding + 10)) + ((kSectionHeaderHeight + kTopMargin) + kTopMargin);
                
                // kSectionHeaderHeight should be included for first line only
                CGFloat shelfYOffset = ((i + 1) * (kProgramCellHeight + 27 + 8));
                
                CGSize sizeForShelfView = [ShopShelfView sizeForShelfView];
                decorationAttributes.frame = CGRectMake(0, shelfYOffset, sizeForShelfView.width, sizeForShelfView.height);
                
                [mutableLayoutAttributes addObject:decorationAttributes];
            }
//        }        
    }
    
    return mutableLayoutAttributes;
}

- (CGFloat)yOffsetForSection {
    return 0;
}

@end
