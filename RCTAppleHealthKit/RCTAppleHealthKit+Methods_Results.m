//
//  RCTAppleHealthKit+Methods_Results.m
//  RCTAppleHealthKit
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.

#import "RCTAppleHealthKit+Methods_Results.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

#import "RNAppleHealthKit-Swift.h"

@implementation RCTAppleHealthKit (Methods_Results)


- (void)results_getBloodGlucoseSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];

    HKUnit *mmolPerL = [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:mmolPerL];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:bloodGlucoseType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            NSLog(@"An error occured while retrieving the glucose sample %@. The error was: ", error);
            callback(@[RCTMakeError(@"An error occured while retrieving the glucose sample", error, nil)]);
            return;
        }
    }];
}

- (void)results_getCarbohydratesSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *carbohydratesType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKUnit *unit = [self.rnAppleHealthKit hkUnitFrom:input with:@"unit" defaultValue:[HKUnit gramUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:carbohydratesType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            NSLog(@"An error occured while retrieving the carbohydates sample %@. The error was: ", error);
            callback(@[RCTMakeError(@"An error occured while retrieving the carbohydates sample", error, nil)]);
            return;
        }
    }];
}

- (void)results_saveBloodGlucoseSample:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];

    HKUnit *mmolPerL = [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]];



    HKQuantity *glucoseQuantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
    HKQuantitySample *glucoseSample = [HKQuantitySample quantitySampleWithType:bloodGlucoseType
                                                                      quantity:glucoseQuantity
                                                                     startDate:startDate
                                                                       endDate:endDate
                                                                      metadata:metadata];

    [self.rnAppleHealthKit.healthStore saveObject:glucoseSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured while saving the glucose sample %@. The error was: ", error);
            callback(@[RCTMakeError(@"An error occured while saving the glucose sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], [glucoseSample.UUID UUIDString]]);
    }];
}

- (void)results_saveCarbohydratesSample:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *carbohydratesType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];


    HKQuantity *carbQuantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
    HKQuantitySample *carbSample = [HKQuantitySample quantitySampleWithType:carbohydratesType
                                                                   quantity:carbQuantity
                                                                  startDate:sampleDate
                                                                    endDate:sampleDate
                                                                   metadata:metadata];

    [self.rnAppleHealthKit.healthStore saveObject:carbSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured while saving the carbohydrate sample %@. The error was: ", error);
            callback(@[RCTMakeError(@"An error occured while saving the carbohydrate sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], [carbSample.UUID UUIDString]]);
    }];
}

- (void)results_deleteBloodGlucoseSample:(NSString *)oid callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:oid];
    NSPredicate *uuidPredicate = [HKQuery predicateForObjectWithUUID:uuid];
    [self.healthStore deleteObjectsOfType:bloodGlucoseType predicate:uuidPredicate withCompletion:^(BOOL success, NSUInteger deletedObjectCount, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"An error occured while deleting the glucose sample %@. The error was: ", error);
            callback(@[RCTMakeError(@"An error occured while deleting the glucose sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(deletedObjectCount)]);
    }];
}

- (void)results_deleteCarbohydratesSample:(NSString *)oid callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *carbohydratesType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:oid];
    NSPredicate *uuidPredicate = [HKQuery predicateForObjectWithUUID:uuid];
    [self.healthStore deleteObjectsOfType:carbohydratesType predicate:uuidPredicate withCompletion:^(BOOL success, NSUInteger deletedObjectCount, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"An error occured while deleting the carbohydrate sample %@. The error was: ", error);
            callback(@[RCTMakeError(@"An error occured while deleting the carbohydrate sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(deletedObjectCount)]);
    }];
}

@end
