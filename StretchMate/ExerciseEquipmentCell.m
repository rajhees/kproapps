//
//  ExerciseEquipmentCell.m
//  StretchMate
//
//  Created by James Eunson on 16/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseEquipmentCell.h"

#define kHighlightedCellGradient @[ (id)[RGBCOLOR(5, 140, 245) CGColor], (id)[RGBCOLOR(1, 93, 230) CGColor] ]

@interface ExerciseEquipmentCell()
@property (nonatomic, strong) UIImageView * disclosureIndicatorView;
@end

@implementation ExerciseEquipmentCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialise background
        UIImage * cellBackgroundImage = [[UIImage imageNamed:@"exercise-equipment-item-container"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 5, 6, 5)];
        UIImageView * cellBackgroundImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
        cellBackgroundImageView.frame = CGRectMake(0, 0, kExerciseEquipmentCellBoxWidth, kExerciseEquipmentCellBoxHeight);
        [self addSubview:cellBackgroundImageView];
        
        self.disclosureIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-equipment-disclosure-indicator"]];
        self.disclosureIndicatorView.frame = CGRectMake(kExerciseEquipmentCellBoxWidth - self.disclosureIndicatorView.frame.size.width - 5, (kExerciseEquipmentCellBoxHeight / 2) - (self.disclosureIndicatorView.frame.size.height / 2), self.disclosureIndicatorView.frame.size.width, self.disclosureIndicatorView.frame.size.height);
        
        [self addSubview:self.disclosureIndicatorView];
        
        CAGradientLayer * itemHighlightLayer = [CAGradientLayer layer];
        [itemHighlightLayer setFrame:CGRectMake(0, 0, kExerciseEquipmentCellBoxWidth, kExerciseEquipmentCellBoxHeight)];
        itemHighlightLayer.actions = @{@"opacity": [NSNull null]};
        itemHighlightLayer.colors = kHighlightedCellGradient;
        itemHighlightLayer.cornerRadius = 6.0f;
        
        self.itemHighlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kExerciseEquipmentCellBoxWidth, kExerciseEquipmentCellBoxHeight)];
        [_itemHighlightView.layer insertSublayer:itemHighlightLayer atIndex:0];
        _itemHighlightView.alpha = 0.0f;
        [self addSubview:self.itemHighlightView];
        
        self.equipmentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kExerciseEquipmentImageWidth + 10, 2, kExerciseEquipmentCellBoxWidth - (kExerciseEquipmentImageWidth + 30), kExerciseEquipmentCellBoxHeight)];
        _equipmentNameLabel.font = [UIFont systemFontOfSize:12.0f];
        _equipmentNameLabel.textColor = RGBCOLOR(190, 204, 255);
        _equipmentNameLabel.backgroundColor = [UIColor clearColor];
        _equipmentNameLabel.text = @"Test Text";
        _equipmentNameLabel.numberOfLines = 0;
        _equipmentNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _equipmentNameLabel.shadowColor = RGBCOLOR(0, 0, 0);
        _equipmentNameLabel.shadowOffset = CGSizeMake(0, -1);
        
        [self addSubview:self.equipmentNameLabel];
        
        self.equipmentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-filler-image"]];
        
        _equipmentImageView.frame = CGRectMake(4, 4, kExerciseEquipmentImageWidth, kExerciseEquipmentImageHeight);
        _equipmentImageView.layer.cornerRadius = 4.0f;
        _equipmentImageView.layer.masksToBounds = YES;
        
        [self addSubview:_equipmentImageView];
    }
    return self;
}

- (void)setEquipmentString:(NSString *)equipmentString {
    _equipmentString = equipmentString;
    
    self.equipmentNameLabel.text = equipmentString;
}

@end
