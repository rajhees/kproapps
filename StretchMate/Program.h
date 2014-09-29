//
//  Program.h
//  StretchMate
//
//  Created by James Eunson on 12/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    OverviewImageTypeNormal,
    OverviewImageTypeThumbnail
} OverviewImageType;

@class Exercise;

@interface Program : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * programDescription;
@property (nonatomic, retain) NSSet *exercises;

+ (Program*)programForIdentifier:(NSNumber*)identifier;

- (NSString*)getExerciseString;
- (UIImage*)getOverviewImageWithSize:(CGSize)sizeForOverviewImage type:(OverviewImageType)type;

- (NSInteger)completionTimeInMinutes;
- (NSString*)getCompletionTimeString;
- (NSString*)getShortCompletionTimeString; // For use in ProgramsViewController collectionview cell

@property (nonatomic, strong) NSArray * timeslots;

@end

@interface Program (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(Exercise *)value;
- (void)removeExercisesObject:(Exercise *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;

@end
