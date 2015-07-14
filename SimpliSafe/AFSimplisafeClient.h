//
//  AFSimplisafeClient.h
//  SimpliSafe
//
//  Created by Scott Newman on 5/31/13.
//  Copyright (c) 2013 Newman Creative. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFSimplisafeClient : AFHTTPClient

+ (AFSimplisafeClient *)sharedClient;

@end
