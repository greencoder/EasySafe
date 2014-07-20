//
//  SSLocation.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSLocation : NSObject

typedef NS_ENUM(NSInteger, SSSystemState) {
    SSSystemStateUnknown = -1,
    SSSystemStateOff,
    SSSystemStateHome,
    SSSystemStateAway,
};

@property (nonatomic, strong) NSString *locationID;
@property (nonatomic, strong) NSString *street1;
@property (nonatomic, strong) NSString *street2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign) SSSystemState systemState;

+ (NSString *)nameForSystemState:(SSSystemState)systemState;
+ (SSSystemState)systemStateForName:(NSString *)stateName;

@end
