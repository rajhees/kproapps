//
//  PractitionerExercise.h
//  Exersite
//
//  Created by James Eunson on 20/08/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "MTLModel.h"

@interface PractitionerExercise : MTLModel

@property (nonatomic, copy, readonly) NSNumber * identifier;

@property (nonatomic, copy, readonly) NSString * nameBasic;
@property (nonatomic, copy, readonly) NSString * nameTechnical;
@property (nonatomic, copy, readonly) NSString * purpose;

@property (nonatomic, copy, readonly) NSString * image;
@property (nonatomic, copy, readonly) NSString * thumb;

@property (nonatomic, copy, readonly) NSNumber * level;
@property (nonatomic, copy, readonly) NSNumber * location;
@property (nonatomic, copy, readonly) NSNumber * seconds;

@property (nonatomic, copy, readonly) NSArray * instructions;
@property (nonatomic, copy, readonly) NSArray * equipment;
@property (nonatomic, copy, readonly) NSArray * types;

@property (nonatomic, assign, getter = isCompleted) BOOL completed;

- (NSString*)typesString;
- (NSString*)getLevelString;
- (NSString*)getLevelExplanationString;

@end
