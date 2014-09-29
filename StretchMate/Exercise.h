//
//  Exercise.h
//  Exersite
//
//  Created by James Eunson on 27/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kBasicExplanationString @"Recommended for everyone"
#define kIntermediateExplanationString @"May require some experience to complete"
#define kAdvancedExplanationString @"Practitioner guidance or experience recommended"

#define kIndicatorLocations @{ @"Ankle & Foot": @[@180, @580], @"Core & Pilates": @[@420, @300], @"Elbow & Wrist": @[@140, @240], @"Hip": @[@180, @340], @"Knee": @[@425, @460], @"Lower Back (Lumbar)": @[@420, @300], @"Neck (Cervical)": @[@400, @125], @"Jaw (TMJ)": @[@200, @125], @"Shoulder": @[@440, @140], @"Upper Back (Thoracic)": @[@180, @190] }

typedef enum {
    
    ExerciseLocationAnkleFoot,
    ExerciseLocationCore,
    ExerciseLocationElbowWrist,
    ExerciseLocationHip,
    ExerciseLocationJaw,
    ExerciseLocationKnee,
    ExerciseLocationLumbar,
    ExerciseLocationNeck,
    ExerciseLocationShoulder,
    ExerciseLocationThoracic,
    
} ExerciseLocation;

typedef enum {
    
    ExerciseFilterTypeLocation,
    ExerciseFilterTypeExerciseType
    
} ExerciseFilterType;

typedef enum {
    
    ExerciseLevelBasic,
    ExerciseLevelIntermediate,
    ExerciseLevelAdvanced
    
} ExerciseLevel;

#define kExerciseLevelLabels @{@(ExerciseLevelBasic): @"Basic", @(ExerciseLevelIntermediate): @"Intermediate", @(ExerciseLevelAdvanced) : @"Advanced" }

#define kExerciseLocationLookupHash @{@"Ankle & Foot": @(ExerciseLocationAnkleFoot), @"Core & Pilates": @(ExerciseLocationCore), @"Elbow & Wrist": @(ExerciseLocationElbowWrist), @"Hip": @(ExerciseLocationHip), @"Jaw (TMJ)": @(ExerciseLocationJaw), @"Knee": @(ExerciseLocationKnee), @"Lower Back (Lumbar)": @(ExerciseLocationLumbar), @"Neck (Cervical)": @(ExerciseLocationNeck), @"Shoulder": @(ExerciseLocationShoulder), @"Upper Back (Thoracic)": @(ExerciseLocationThoracic)}

#define kExerciseFilterTypes @[@"Body Location", @"Exercise Type"]

#define kExerciseLocationsFront @[@(ExerciseLocationAnkleFoot), @(ExerciseLocationCore), @(ExerciseLocationElbowWrist), @(ExerciseLocationJaw), @(ExerciseLocationKnee), @(ExerciseLocationShoulder)]
#define kExerciseLocationsBack @[@(ExerciseLocationLumbar), @(ExerciseLocationNeck), @(ExerciseLocationHip), @(ExerciseLocationThoracic)]

@class Exercise, ExerciseType, Program;

@interface Exercise : NSManagedObject

@property (nonatomic, retain) NSString * equipment;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) id instructions;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) NSString * nameBasic;
@property (nonatomic, retain) NSString * nameTechnical;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * purpose;
@property (nonatomic, retain) NSNumber * seconds;
@property (nonatomic, retain) NSSet *programs;
@property (nonatomic, retain) NSSet *types;
@property (nonatomic, retain) NSSet *related;

@property (nonatomic, strong) NSArray * tempProcessedInstructionsList;

@property (nonatomic, assign, getter = isCanonical, readonly) BOOL canonical;
@property (nonatomic, strong) Exercise * canonicalExercise;

// If canonical, returns name technical, otherwise returns self.canonicalExercise.nameTechnical
@property (nonatomic, strong, readonly) NSString * canonicalNameTechnical;
@property (nonatomic, strong, readonly) NSString * canonicalNameBasic;
@property (nonatomic, strong, readonly) NSString * canonicalNumber;

// Cached array, so as to preserve ordering between UITableViewCell row retrievals
@property (nonatomic, strong, readonly) NSArray * relatedExercises;

@property (nonatomic, assign, getter = isCompleted) BOOL completed;
@property (nonatomic, assign) NSInteger programExerciseTimeIdentifier;

+ (NSNumber*)getTypeForLocationString:(NSString*)locationString;
+ (NSArray*)sortedExerciseLocations;
+ (NSArray*)updateOverlappedWithExerciseInExerciseArray:(NSArray*)exerciseArray;
+ (NSDictionary*)categorizeExercisesByDifficulty:(NSArray*)rawExercises;
+ (NSArray*)generateDifficultiesForCategorizedExercises:(NSDictionary*)exercises;

+ (Exercise*)exerciseWithIdentifier:(NSNumber*)identifier;

- (NSString*)locationString;
- (NSArray*)getInstructionList;
- (NSString*)typesString;
- (BOOL)isExerciseSaved;
- (BOOL)isExercisePrescribed;
- (void)toggleExerciseSaved;
- (NSArray*)getImages;
- (NSArray*)getImagePaths;
- (UIImage*)getThumbnailImage;
- (NSArray*)getEquipment;
- (UIImage*)getLevelImage;
- (NSString*)getLevelString;
- (NSString*)getLevelExplanationString;
- (NSString*)durationString;

- (NSString*)getVideoFilePath;

@end

@interface Exercise (CoreDataGeneratedAccessors)

- (void)addProgramsObject:(Program *)value;
- (void)removeProgramsObject:(Program *)value;
- (void)addPrograms:(NSSet *)values;
- (void)removePrograms:(NSSet *)values;

- (void)addTypesObject:(ExerciseType *)value;
- (void)removeTypesObject:(ExerciseType *)value;
- (void)addTypes:(NSSet *)values;
- (void)removeTypes:(NSSet *)values;

- (void)addRelatedObject:(Exercise *)value;
- (void)removeRelatedObject:(Exercise *)value;
- (void)addRelated:(NSSet *)values;
- (void)removeRelated:(NSSet *)values;

@end
