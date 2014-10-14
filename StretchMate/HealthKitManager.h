//
//  HealthKitManager.h
//  Exersite
//
//  Created by Frank on 10/8/14.
//  Copyright (c) 2014 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HealthKitManager : NSObject

+ (void)saveTimeToHealthKitStore:(int)timeInSecs;
@end
