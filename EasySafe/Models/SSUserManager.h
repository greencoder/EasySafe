//
//  SSUserManager.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/13/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@class SSUser;
@class SSLocation;

@interface SSUserManager : AFHTTPSessionManager

@property (nonatomic, strong) SSUser *user;
@property (nonatomic, strong) SSLocation *currentLocation;

@property (nonatomic, strong) NSString *lastSessionToken;

@property (nonatomic, strong) NSString *savedUsername;
@property (nonatomic, strong) NSString *savedPassword;

@property (nonatomic, assign) BOOL networkIsReachable;

+ (SSUserManager *)sharedManager;

- (void)clearSessionToken;
- (void)clearSavedUsername;
- (void)clearSavedPassword;

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                 completion:(void(^)(SSUser *user, NSError *error))completion;

- (NSURLSessionDataTask *)validateSession:(NSString *)sessionToken
                           withCompletion:(void(^)(SSUser *user, NSError *error))completion;

@end
