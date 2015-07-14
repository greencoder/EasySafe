//
//  SSDashboard.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/15/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSEvent;

@interface SSDashboard : NSObject

@property (nonatomic, strong) NSString *accountNumber;

@property (nonatomic, strong) NSString *monitoringCenterName;
@property (nonatomic, strong) NSString *monitoringCenterPhone;

@property (nonatomic, strong) NSString *temperature;
@property (nonatomic, strong) NSString *temperatureRecorded;

@property (nonatomic, strong) SSEvent *fireEvent;
@property (nonatomic, strong) SSEvent *coEvent;
@property (nonatomic, strong) SSEvent *floodEvent;
@property (nonatomic, strong) SSEvent *alarmEvent;

@end
