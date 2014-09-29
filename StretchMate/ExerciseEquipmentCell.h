//
//  ExerciseEquipmentCell.h
//  StretchMate
//
//  Created by James Eunson on 16/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kExerciseEquipmentCellBoxHeight 69
#define kExerciseEquipmentCellBoxWidth 140
#define kExerciseEquipmentImageHeight 60
#define kExerciseEquipmentImageWidth 60

@interface ExerciseEquipmentCell : UICollectionViewCell

@property (nonatomic, strong) NSString * equipmentString; 
@property (nonatomic, strong) UILabel * equipmentNameLabel;
@property (nonatomic, strong) UIView * itemHighlightView;

@property (nonatomic, strong) UIImageView * equipmentImageView;

@end
