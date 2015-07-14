//
//  SSUserManager.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/13/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "SSUserManager.h"
#import "SSUser.h"

#import "AFNetworkReachabilityManager.h"
#import "MMKeychain.h"

@implementation SSUserManager

+ (SSUserManager *)sharedManager
{
    static SSUserManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSURL *baseURL = [NSURL URLWithString:@"https://simplisafe.com"];
        
        // Don't use the production URL if we set kSSUseDebugURL to YES in constants.h
        if (kSSUseDebugURL)
            baseURL = [NSURL URLWithString:@"http://192.168.1.123:5000"];

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:@{@"User-Agent": @"SimpiSafe Better App"}];
        _sharedManager = [[SSUserManager alloc] initWithBaseURL:baseURL sessionConfiguration:config];
        _sharedManager.responseSerializer.acceptableContentTypes =
            [NSSet setWithObjects:@"text/plain", @"application/json", @"text/html", @"text/javascript", nil];
    });
    return _sharedManager;
}

- (NSURLSessionDataTask *)validateSession:(NSString *)sessionToken
                           withCompletion:(void(^)(SSUser *user, NSError *error))completion
{
    NSDictionary *postParams = @{
                                 @"validate": sessionToken,
                                 @"version": @"1200",
                                 @"no_persist": @"0",
                                 @"XDEBUG_SESSION_START": @"session_name",
                                 };
    
    NSURLSessionDataTask *task = [self POST:@"/mobile/login/" parameters:postParams
                                    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary *responseDict = (NSDictionary *)responseObject;
      
        // SimpliSafe doesn't follow good practice here. If you have an invalid login, you
        // will get a 200 response but the property "return_code" will be 0.
      
        if (httpResponse.statusCode == 200)
        {
            // Not a good login, according to the return value
            if ([responseDict[@"return_code"] intValue] == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Bad Login");
                    completion(nil, nil);
                });
            }

            // A good login
            else
            {
                // Create a user from the response
                NSDictionary *responseDict = (NSDictionary *)responseObject;
                SSUser *user = [SSUser new];
                user.userName = responseDict[@"username"];
                user.sessionToken = responseDict[@"session"];
                user.userID = responseDict[@"uid"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(user, nil);
                });
            }

        }

        // We didn't get a 200
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Not a 200 response.");
                completion(nil, nil);
            });
        }
    }
    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Failure");
            completion(nil, error);
        });

    }];
    return task;
}

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                 completion:(void(^)(SSUser *user, NSError *error))completion
{
    NSDictionary *postParams = @{
                                 @"name": username,
                                 @"pass": password,
                                 @"device_name": @"iPhone",
                                 @"device_uuid": @"EEEF5CC2-82D8-46F5-B634-7FE7004126C3",
                                 @"version": @"1200",
                                 @"no_persist": @"0",
                                 @"XDEBUG_SESSION_START": @"session_name",
                                 };
    
    NSURLSessionDataTask *task = [self POST:@"/mobile/login/"
                                 parameters:postParams
                                    success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        
        // SimpliSafe doesn't follow good API practice here. If you have an invalid login, you
        // will get a 200 response but the property "return_code" will be 0.
        
        if (httpResponse.statusCode == 200)
        {
            // See if it was a good login
            if ([responseDict[@"return_code"] intValue] == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Bad Login");
                    completion(nil, nil);
                });
            }
            else
            {
                // Create a user from the response
                NSDictionary *responseDict = (NSDictionary *)responseObject;
                SSUser *user = [SSUser new];
                user.userName = responseDict[@"username"];
                user.sessionToken = responseDict[@"session"];
                user.userID = responseDict[@"uid"];
              
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Good Login");
                    completion(user, nil);
                });
            }
        }

        // We didn't get a 200
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Not a 200");
                completion(nil, nil);
            });
        }

    }
    failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Error: %@", error);
            completion(nil, error);
        });

    }];
    return task;
}

#pragma mark Properties and Methods

- (NSString *)lastSessionToken
{
    NSString *token = [MMKeychain stringForKey:@"sessionToken"];
    return token;
}

- (void)setLastSessionToken:(NSString *)sessionToken
{
    [MMKeychain setString:sessionToken forKey:@"sessionToken"];
}

- (NSString *)savedPassword
{
    return [MMKeychain stringForKey:@"password"];
}

- (void)setSavedPassword:(NSString *)savedPassword
{
    [MMKeychain setString:savedPassword forKey:@"password"];
}

- (NSString *)savedUsername
{
    return [MMKeychain stringForKey:@"username"];
}

- (void)setSavedUsername:(NSString *)savedUsername
{
    [MMKeychain setString:savedUsername forKey:@"username"];
}

- (void)clearSessionToken
{
    [MMKeychain deleteStringForKey:@"sessionToken"];
}

- (void)clearSavedUsername
{
    [MMKeychain deleteStringForKey:@"username"];
}

- (void)clearSavedPassword
{
    [MMKeychain deleteStringForKey:@"password"];
}


@end
