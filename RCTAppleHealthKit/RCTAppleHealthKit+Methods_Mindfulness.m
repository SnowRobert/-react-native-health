//
//  RCTAppleHealthKit+Methods_Mindfulness.m
//  RCTAppleHealthKit
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.

#import "RCTAppleHealthKit+Methods_Mindfulness.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"



- (void)mindfulness_getMindfulSession:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    double limit = [RCTAppleHealthKit doubleFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]
        initWithKey:HKSampleSortIdentifierEndDate
        ascending:NO
    ];

    HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier: HKCategoryTypeIdentifierMindfulSession];
    NSPredicate *predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];

    HKSampleQuery *query = [[HKSampleQuery alloc]
        initWithSampleType:type
        predicate:predicate
        limit: limit
        sortDescriptors:@[timeSortDescriptor]
        resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {

            if (error != nil) {
            NSLog(@"error with fetchCumulativeSumStatisticsCollection: %@", error);
            callback(@[RCTMakeError(@"error with fetchCumulativeSumStatisticsCollection", error, nil)]);
            return;
            }
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:(10)];

            for (HKQuantitySample *sample in results) {
            NSLog(@"sample for mindfulsession %@", sample);
            NSString *startDateString = [self.rnAppleHealthKit buildISO8601StringFrom:sample.startDate];
            NSString *endDateString = [self.rnAppleHealthKit buildISO8601StringFrom:sample.endDate];

            NSDictionary *elem = @{
                    @"startDate" : startDateString,
                    @"endDate" : endDateString,
            };

            [data addObject:elem];
        }
        callback(@[[NSNull null], data]);
     }
    ];
    [self.rnAppleHealthKit.healthStore executeQuery:query];
}

- (void)mindfulness_saveMindfulSession:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double value = [RCTAppleHealthKit doubleFromOptions:input key:@"value" withDefault:(double)0];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];

    if(startDate == nil || endDate == nil){
        callback(@[RCTMakeError(@"startDate and endDate are required in options", nil, nil)]);
        return;
    }

    HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier: HKCategoryTypeIdentifierMindfulSession];
    HKCategorySample *sample = [HKCategorySample categorySampleWithType:type value:value startDate:startDate endDate:endDate];


    [self.rnAppleHealthKit.healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
        callback(@[[NSNull null], @(value)]);
    }];

}


@end
