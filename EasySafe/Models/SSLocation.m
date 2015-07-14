//
//  SSLocation.m
//  SimpliSafe
//
//  Created by Scott Newman on 7/12/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import "SSLocation.h"

@implementation SSLocation

- (NSString *)description
{
    return self.street1;
}

+ (NSString *)nameForSystemState:(SSSystemState)systemState
{
    if (systemState == SSSystemStateAway)
        return @"Away";
    else if (systemState == SSSystemStateHome)
        return @"Home";
    else if (systemState == SSSystemStateOff)
        return @"Off";
    else
        return @"Unknown";
}

+ (SSSystemState)systemStateForName:(NSString *)stateName
{
    if ([stateName isEqualToString:@"Off"])
        return SSSystemStateOff;
    else if ([stateName isEqualToString:@"Home"])
        return SSSystemStateHome;
    else if ([stateName isEqualToString:@"Away"])
        return SSSystemStateAway;
    else
        return SSSystemStateUnknown;
}

@end
