//
//  SSUser.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUser : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *accountNumber;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *drupalID;
@property (nonatomic, strong) NSString *vid;
@property (nonatomic, strong) NSString *sid;

@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) NSString *sessionName;

@property (nonatomic, strong) NSString *sslSessionToken;
@property (nonatomic, strong) NSString *sslSessionName;

@property (nonatomic, strong) NSArray *locations;

@end
