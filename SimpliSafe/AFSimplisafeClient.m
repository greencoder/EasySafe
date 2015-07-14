//
//  AFSimplisafeClient.m
//  SimpliSafe
//
//  Created by Scott Newman on 5/31/13.
//  Copyright (c) 2013 Newman Creative. All rights reserved.
//

#import "AFSimplisafeClient.h"
#import "AFJSONRequestOperation.h"

@implementation AFSimplisafeClient

+ (AFSimplisafeClient *)sharedClient {
    static AFSimplisafeClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AFSimplisafeClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://simplisafe.com"]];
    });
    
    return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return self;
}

@end