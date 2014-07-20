//
//  SSEvent.h
//  SimpliSafe
//
//  Created by Scott Newman on 7/15/14.
//  Copyright (c) 2014 Newman Creative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSEvent : NSObject

@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSString *recorded;

@end
