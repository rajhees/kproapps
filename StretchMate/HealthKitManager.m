//
//  HealthKitManager.m
//  Exersite
//
//  Created by Frank on 10/8/14.
//  Copyright (c) 2014 James Eunson. All rights reserved.
//

#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>
@implementation HealthKitManager
static HKHealthStore *instance = NULL;

+ (HKHealthStore *)getStoreInstance
{
    if (instance == NULL) {
        instance = [[HKHealthStore alloc] init];
    }
    return instance;
}
+ (void)saveTimeToHealthKitStore:(int)timeInSecs
{
     if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
     {
         NSLog(@"HealthKit is only supported by iOS8");
         return;
     }
    __block HKHealthStore *healthStore = [HealthKitManager getStoreInstance];
    [healthStore requestAuthorizationToShareTypes:[NSSet setWithObject:[HKWorkoutType workoutType]] readTypes:nil completion:^(BOOL success, NSError *error) {
        
        if (success){
            
            HKWorkout *workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypePreparationAndRecovery startDate:[NSDate dateWithTimeIntervalSinceNow:-timeInSecs] endDate:[NSDate date] duration:timeInSecs totalEnergyBurned:[HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:timeInSecs / 60.0 * 4] totalDistance:nil metadata:nil];
            
            [healthStore saveObject:workout withCompletion:^(BOOL success, NSError *error) {
                NSLog(@"Success? %d", success);
                if (error){
                    NSLog(@"Error: %@", error);
                }
            }];
        } else {
            NSLog(@"Failed to Auth with HealthKit Error = %@", error);
        }
        
    }];
    
  [healthStore requestAuthorizationToShareTypes:[NSSet setWithObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned]] readTypes:nil completion:
   ^(BOOL success, NSError *error) {
       if (success) {
           HKQuantityType *fitType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
           HKQuantity *amount = [HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:timeInSecs / 60.0 * 4];
           NSDate *now = [NSDate date];
           HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:fitType quantity:amount startDate:now endDate:now];
           
           [healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error) {
               if (!success) {
                   NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", sample, error);
                   abort();
               }
               
           }];
           
       } else {
           
       }
   }];
    
}


@end
