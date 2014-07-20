//
//  SSAPIClient.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "SSAPIClient.h"

#import "SSUser.h"
#import "SSLocation.h"
#import "SSEvent.h"
#import "SSDashboard.h"

@implementation SSAPIClient

+ (SSAPIClient *)sharedClient
{
    static SSAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL *baseURL = [NSURL URLWithString:@"https://simplisafe.com"];
        
        // Don't use the production URL if we set kSSUseDebugURL to YES in constants.h
        if (kSSUseDebugURL)
            baseURL = [NSURL URLWithString:@"http://192.168.1.123:5000"];
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{@"User-Agent": @"SimpiSafe Better App"}];
        _sharedClient = [[SSAPIClient alloc] initWithBaseURL:baseURL sessionConfiguration:config];
        _sharedClient.responseSerializer.acceptableContentTypes =
            [NSSet setWithObjects:@"text/plain", @"application/json", @"text/html", @"text/javascript", nil];
    });
    return _sharedClient;
}

- (NSURLSessionDataTask *)fetchDashboardForLocation:(SSLocation *)location
                                               user:(SSUser *)user
                                         completion:(void(^)(SSDashboard *dashboard, NSError *error))completion
{
    NSString *urlString = [NSString stringWithFormat:@"/mobile/%@/sid/%@/dashboard", user.userID, location.locationID];
    
    NSDictionary *postParams = @{
                                 @"sid": user.userID,
                                 @"no_persist": @"0",
                                 @"XDEBUG_SESSION_START": @"session_name",
                                 };
    
    
    NSURLSessionDataTask *task = [self POST:urlString parameters:postParams
                                    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary *responseDict = (NSDictionary *)responseObject;

        // Check the status code. "success" doesn't mean that it returned a 200
        if (!httpResponse.statusCode == 200)
        {
            // Send back a nil response on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Not a 200 response");
                completion(nil, nil);
            });
            return;
        }
        
        // SimpliSafe will give us a return_code of 0 or 1 to denote if the
        // request was successful or not
        
        // Not a good request
        if ([responseDict[@"return_code"] intValue] == 0)
        {
            // Send back a nil response on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil);
            });
        }

        // Good response
        else
        {
            SSDashboard *dashboard = [SSDashboard new];
            dashboard.accountNumber = responseDict[@"location"][@"service"][@"account"];
            dashboard.monitoringCenterName = responseDict[@"location"][@"monitoring"][@"center"][@"name"];
            dashboard.monitoringCenterPhone = responseDict[@"location"][@"monitoring"][@"center"][@"phone"];
            
            // Create events
            SSEvent *fireEvent = [SSEvent new];
            fireEvent.detail = responseDict[@"location"][@"monitoring"][@"recent_fire"][@"text"];
            fireEvent.recorded = responseDict[@"location"][@"monitoring"][@"recent_fire"][@"time"];
            dashboard.fireEvent = fireEvent;
            
            SSEvent *coEvent = [SSEvent new];
            coEvent.detail = responseDict[@"location"][@"monitoring"][@"recent_co"][@"text"];
            coEvent.recorded = responseDict[@"location"][@"monitoring"][@"recent_co"][@"time"];
            dashboard.coEvent = coEvent;
            
            SSEvent *floodEvent = [SSEvent new];
            floodEvent.detail = responseDict[@"location"][@"monitoring"][@"recent_flood"][@"text"];
            floodEvent.recorded = responseDict[@"location"][@"monitoring"][@"recent_flood"][@"time"];
            dashboard.floodEvent = floodEvent;

            SSEvent *alarmEvent = [SSEvent new];
            alarmEvent.detail = responseDict[@"location"][@"monitoring"][@"recent_alarm"][@"text"];
            alarmEvent.recorded = responseDict[@"location"][@"monitoring"][@"recent_alarm"][@"time"];
            dashboard.alarmEvent = alarmEvent;

            // Get the temperature
            NSNumber *temperatureValue = responseDict[@"location"][@"monitoring"][@"freeze"][@"temp"];
            dashboard.temperature = [NSString stringWithFormat:@"%@°", temperatureValue];
            dashboard.temperatureRecorded = responseDict[@"location"][@"monitoring"][@"freeze"][@"time"];
            
            // Send back a dashboard response
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(dashboard, nil);
            });
            
        }
        
    }
    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];

    return task;
}

- (NSURLSessionDataTask *)fetchEventsForLocation:(SSLocation *)location
                                            user:(SSUser *)user
                                      completion:(void(^)(NSArray *events, NSError *error))completion
{
    NSString *urlString = [NSString stringWithFormat:@"/mobile/%@/sid/%@/events", user.userID, location.locationID];
    
    NSDictionary *postParams = @{
                                 @"no_persist": @"0",
                                 @"XDEBUG_SESSION_START": @"session_name",
                                 };
    
    NSURLSessionDataTask *task = [self POST:urlString parameters:postParams
    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (NSDictionary *eventDict in responseObject[@"events"])
        {
            SSEvent *event = [SSEvent new];
            
            // Replace any escaped characters
            event.detail = [eventDict[@"event_desc"] stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            
            event.recorded = [NSString stringWithFormat:@"%@ - %@", eventDict[@"event_time"], eventDict[@"event_date"]];
            [events addObject:event];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(events, nil);
        });
    }
    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
    return task;
}

- (NSURLSessionDataTask *)changeStateForLocation:(SSLocation *)location
                                            user:(SSUser *)user
                                           state:(NSString *)newStateName
                                      completion:(void(^)(SSSystemState systemState, NSError *error))completion
{
    NSString *urlString = [NSString stringWithFormat:@"/mobile/%@/sid/%@/set-state", user.userID, location.locationID];

    NSDictionary *postParams =
    @{
        @"no_persist": @"0",
        @"mobile": @"1",
        @"state": newStateName,
        @"XDEBUG_SESSION_START": @"session_name",
    };
    
    NSURLSessionDataTask *task = [self POST:urlString parameters:postParams
                                    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        
        int resultCode = [responseDict[@"result"] intValue];
        SSSystemState resultState;
        
        switch (resultCode)
        {
            case 2:
                resultState = SSSystemStateOff;
                break;
            case 4:
                resultState = SSSystemStateHome;
                break;
            case 5:
                resultState = SSSystemStateAway;
                break;
            default:
                resultState = SSSystemStateUnknown;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(resultState, nil);
        });

    }
    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"error: %@", error);
            completion(SSSystemStateUnknown, error);
        });
    }];
    
    return task;
    
}

- (NSURLSessionDataTask *)fetchLocationsForUser:(SSUser *)user
                                 completion:(void(^)(NSArray *locations, NSError *error))completion
{
    NSString *urlString = [NSString stringWithFormat:@"/mobile/%@/locations", user.userID];

    NSDictionary *postParams =
    @{
      @"no_persist": @"0",
      @"XDEBUG_SESSION_START": @"session_name",
    };
    
    NSURLSessionDataTask *task = [self POST:urlString parameters:postParams
        success:^(NSURLSessionDataTask *task, id responseObject)
        {
            NSMutableArray *locations = [[NSMutableArray alloc] init];
            for (NSString *key in responseObject[@"locations"])
            {
                NSDictionary *itemDict = responseObject[@"locations"][key];
                SSLocation *location = [SSLocation new];
                location.locationID = key;
                location.street1 = itemDict[@"street1"];
                location.street2 = itemDict[@"street2"];
                location.city = itemDict[@"city"];
                location.state = itemDict[@"state"];
                location.postalCode = itemDict[@"postal_code"];
                location.status = itemDict[@"s_status"];
                location.systemState = [SSLocation systemStateForName:itemDict[@"system_state"]];
                [locations addObject:location];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(locations, nil);
            });
        }
        failure:^(NSURLSessionDataTask *task, NSError *error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
        }];

    return task;
}

@end
