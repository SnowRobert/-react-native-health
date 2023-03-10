//
//  RCTAppleHealthKit+Methods_LabTests.m
//  RCTAppleHealthKit
//
//  Created by Daniel Rufus Kaldheim on 2020-09-29.
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "RCTAppleHealthKit+Methods_LabTests.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

#import "RNAppleHealthKit-Swift.h"

@implementation RCTAppleHealthKit (Methods_LabTests)


- (void)labTests_getLatestBloodAlcoholContent:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback {
    
    HKQuantityType *bloodAlcoholContentType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    
    HKUnit *unit = [self.rnAppleHealthKit hkUnitFrom:input with:@"unit" defaultValue:[HKUnit percentUnit]];
    
    [self fetchMostRecentQuantitySampleOfType:bloodAlcoholContentType
                                    predicate:nil
                                   completion:^(HKQuantity *mostRecentQuantity, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (!mostRecentQuantity) {
            callback(@[RCTJSErrorFromNSError(error)]);
        }
        else {
            // Determine the weight in the required unit.
            double usersBloodAlcoholContent = [mostRecentQuantity doubleValueForUnit:unit];
            NSDictionary *response = @{
                    @"value" : @(usersBloodAlcoholContent),
                    @"startDate" : [self.rnAppleHealthKit buildISO8601StringFrom:startDate],
                    @"endDate" : [self.rnAppleHealthKit buildISO8601StringFrom:endDate],
            };

            callback(@[[NSNull null], response]);
        }
    }];
}
    
- (void)labTests_getBloodAlcoholContentSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback {
    
    HKQuantityType *bloodAlcoholContentType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];

    HKUnit *unit = [self.rnAppleHealthKit hkUnitFrom:input with:@"unit" defaultValue:[HKUnit percentUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:bloodAlcoholContentType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
    }];
    
}
    
- (void)labTests_saveBloodAlcoholContent:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double bloodAlcoholContent = [[input objectForKey:@"value"] doubleValue];
    NSDate *sampleDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:[NSDate date]];
    HKUnit *unit = [self.rnAppleHealthKit hkUnitFrom:input with:@"unit" defaultValue:[HKUnit percentUnit]];

    HKQuantity *bloodAlcoholContentQuantity = [HKQuantity quantityWithUnit:unit doubleValue:bloodAlcoholContent];
    HKQuantityType *bloodAlcoholContentType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    HKQuantitySample *bloodAcloholContentSample = [HKQuantitySample quantitySampleWithType:bloodAlcoholContentType quantity:bloodAlcoholContentQuantity startDate:sampleDate endDate:sampleDate];

    [self.rnAppleHealthKit.healthStore saveObject:bloodAcloholContentSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
        callback(@[[NSNull null], @(bloodAlcoholContent)]);
    }];
}

@end
