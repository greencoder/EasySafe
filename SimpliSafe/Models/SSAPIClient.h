//
//  SSAPIClient.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

#import "SSLocation.h"

@class SSUser;
@class SSLocation;
@class SSDashboard;

@interface SSAPIClient : AFHTTPSessionManager

@property (nonatomic, assign) BOOL networkIsReachable;

+ (SSAPIClient *)sharedClient;

- (NSURLSessionDataTask *)fetchLocationsForUser:(SSUser *)user
                                     completion:(void(^)(NSArray *locations, NSError *error))completion;

- (NSURLSessionDataTask *)fetchEventsForLocation:(SSLocation *)location
                                            user:(SSUser *)user
                                      completion:(void(^)(NSArray *events, NSError *error))completion;

- (NSURLSessionDataTask *)fetchDashboardForLocation:(SSLocation *)location
                                               user:(SSUser *)user
                                         completion:(void(^)(SSDashboard *dashboard, NSError *error))completion;

- (NSURLSessionDataTask *)changeStateForLocation:(SSLocation *)location
                                            user:(SSUser *)user
                                           state:(NSString *)newStateName
                                      completion:(void(^)(SSSystemState systemState, NSError *error))completion;

@end
